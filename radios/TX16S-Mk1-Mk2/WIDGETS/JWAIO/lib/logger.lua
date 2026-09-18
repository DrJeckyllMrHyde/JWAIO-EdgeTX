-- ============================================================================
-- JWAIO - Jeckyll Widget All in One
-- Copyright 2026 DrJeckyllMrHyde
-- SPDX-License-Identifier: Apache-2.0
-- Fichier : lib/logger.lua
-- Version : 0.3.1 Alpha
-- Role    : journal CSV a 1 Hz et conservation de la derniere position GPS.
-- ============================================================================

return function(config, util)
  local M = {}

  local function numberOrBlank(value, precision)
    if type(value) ~= "number" or value ~= value or
       value == math.huge or value == -math.huge then return "" end
    return string.format("%." .. tostring(precision or 2) .. "f", value)
  end

  local function fileExists(path)
    local handle = io.open(path, "r")
    if not handle then return false end
    io.close(handle)
    return true
  end

  function M.availableFilename(prefix)
    local base = config.logPath .. "/" .. prefix .. util.fileStamp()
    local filename = base .. ".csv"
    if not fileExists(filename) then return filename end
    -- Le suffixe empeche deux armements pendant la meme seconde d'ecraser le
    -- meme vol. La recherche reste volontairement bornee a 99 collisions.
    for index = 1, 99 do
      filename = string.format("%s_%02d.csv", base, index)
      if not fileExists(filename) then return filename end
    end
    -- Ne jamais ecraser le dernier fichier si tous les suffixes sont occupes.
    return nil
  end

  function M.new()
    return {
      active = false,
      nextWrite = 0,
      filename = nil,
      error = nil
    }
  end

  function M.start(logger, now)
    if logger.active then return true end
    logger.filename = M.availableFilename("F")
    if not logger.filename then logger.error = "LOG NAMES"; return false end
    local handle = io.open(logger.filename, "w")
    if not handle then
      logger.error = "LOG OPEN"
      logger.active = false
      return false
    end
    local ok = io.write(handle,
      "date,time,lat,lon,altitude,speed,cell_v,distance_home_m,distance_total_m,distance_max_m,lq,sats," ..
      "elapsed_s,radio_time_s,armed,prearm,throttle_pct,throttle_valid,pack_v,pack_estimated,batt_raw_v,batt_type,cells," ..
      "rssi_dbm,gps_valid,alt_valid,speed_valid,batt_valid,lq_valid,rssi_valid,sats_valid,distance_valid," ..
      "beeper,flip,rth,finder_active,finder_valid,finder_source,finder_strength_pct,finder_period_s," ..
      "cell_min_v,cell_max_v,throttle_max_pct,samples,nav_age_s,flight_mode,build\n")
    io.close(handle)
    if not ok then
      logger.error = "LOG WRITE"
      logger.active = false
      return false
    end
    logger.active = true
    logger.nextWrite = now
    logger.startedAt = now
    logger.minimum = nil
    logger.maximum = nil
    logger.throttleMaximum = nil
    logger.samples = 0
    logger.finishPending = false
    logger.error = nil
    return true
  end

  function M.stop(logger)
    logger.active = false
    logger.nextWrite = 0
    logger.finishPending = false
  end

  function M.finish(logger)
    -- Le dernier intervalle (sag compris) sera ecrit apres le calcul distance.
    logger.finishPending = logger.active
  end

  function M.update(logger, state, finder)
    if not logger.active or not logger.filename then return end
    -- Observer a chaque tick, ecrire seulement a 1 Hz. Les creux brefs restent
    -- visibles dans min/max sans multiplier les acces au stockage.
    logger.samples = (logger.samples or 0) + 1
    if state.batteryValid and type(state.battery) == "number" then
      logger.minimum = math.min(logger.minimum or state.battery, state.battery)
      logger.maximum = math.max(logger.maximum or state.battery, state.battery)
    end
    if state.throttleValid then
      logger.throttleMaximum = math.max(logger.throttleMaximum or 0, state.throttle)
    end
    if not logger.finishPending and state.now < logger.nextWrite then return end

    local function flag(value) return value and "1" or "0" end
    local finderActive = state.beeper or state.flip or state.rth
    local finderValid = finderActive and finder and finder.valid

    local line = table.concat({
      util.dateText(),
      util.timeText(),
      numberOrBlank(state.gpsValid and state.lat or nil, 7),
      numberOrBlank(state.gpsValid and state.lon or nil, 7),
      numberOrBlank(state.altitudeValid and state.altitude or nil, 1),
      numberOrBlank(state.speedValid and state.speed or nil, 1),
      numberOrBlank(state.batteryValid and state.battery or nil, 2),
      numberOrBlank(state.distanceValid and state.distance or nil, 1),
      numberOrBlank(state.distanceValid and state.totalDistance or nil, 1),
      numberOrBlank(state.distanceValid and state.maxDistance or nil, 1),
      numberOrBlank(state.lqValid and state.lq or nil, 0),
      numberOrBlank(state.satsValid and state.sats or nil, 0),
      numberOrBlank(state.now - (logger.startedAt or state.now), 2),
      numberOrBlank(state.now, 2), flag(state.armed), flag(state.prearmed),
      numberOrBlank(state.throttleValid and state.throttle or nil, 0), flag(state.throttleValid),
      numberOrBlank(state.batteryValid and state.packVoltage or nil, 2), flag(state.packEstimated),
      numberOrBlank(state.batteryRaw, 2), state.batteryType or "", numberOrBlank(state.cells, 0),
      numberOrBlank(state.rssiValid and state.rssi or nil, 0),
      flag(state.gpsValid), flag(state.altitudeValid), flag(state.speedValid), flag(state.batteryValid),
      flag(state.lqValid), flag(state.rssiValid), flag(state.satsValid), flag(state.distanceValid),
      flag(state.beeper), flag(state.flip), flag(state.rth), flag(finderActive), flag(finderValid),
      finderValid and finder.source or "", numberOrBlank(finderValid and finder.strength or nil, 1),
      numberOrBlank(finderValid and finder.period or nil, 2),
      numberOrBlank(logger.minimum, 2), numberOrBlank(logger.maximum, 2),
      numberOrBlank(logger.throttleMaximum, 0), tostring(logger.samples),
      numberOrBlank(state.navigationAt and state.now - state.navigationAt or nil, 2),
      state.mode or "", config.version .. "-" .. config.iteration
    }, ",")

    -- L'API io EdgeTX utilise des fonctions globales (io.write/io.close),
    -- pas les methodes objet standard de Lua. Ouvrir en ajout a chaque
    -- echantillon garantit aussi que la ligne est finalisee sur la carte SD.
    local handle = io.open(logger.filename, "a")
    if not handle then
      logger.error = "LOG APPEND"
      logger.active = false
      return
    end
    local ok = io.write(handle, line, "\n")
    io.close(handle)
    if not ok then
      logger.error = "LOG WRITE"
      logger.active = false
      return
    end
    logger.nextWrite = state.now + config.logPeriodSeconds
    logger.minimum = nil
    logger.maximum = nil
    logger.throttleMaximum = nil
    logger.samples = 0
    -- Conserver aussi la derniere position a chaque echantillon GPS/CSV pour
    -- qu'une coupure d'alimentation ne perde pas la fin du vol.
    M.saveLastPosition(state)
    if logger.finishPending then M.stop(logger) end
  end

  function M.saveLastPosition(state)
    -- Une coordonnee absente ou 0,0 ne doit jamais effacer la derniere position
    -- exploitable apres une coupure de telemetrie ou d'alimentation.
    if not state.lastLat or not state.lastLon then return false end
    if state.lastLat == 0 and state.lastLon == 0 then return false end
    local handle = io.open(config.logPath .. "/lastpos.txt", "w")
    if not handle then return false end
    local ok = io.write(handle, string.format("LAT=%.7f\nLON=%.7f\n", state.lastLat, state.lastLon))
    io.close(handle)
    return ok ~= nil
  end

  function M.loadLastPosition(state)
    -- Lecture par blocs compatible avec l'implementation io simplifiee EdgeTX.
    local handle = io.open(config.logPath .. "/lastpos.txt", "r")
    if not handle then return end
    local chunks = {}
    while true do
      local data = io.read(handle, 64)
      if not data or #data == 0 then break end
      chunks[#chunks + 1] = data
    end
    io.close(handle)
    local content = table.concat(chunks)
    state.lastLat = tonumber(string.match(content, "LAT=([%-%d%.]+)"))
    state.lastLon = tonumber(string.match(content, "LON=([%-%d%.]+)"))
  end

  function M.saveLastDistance(distance)
    -- Ce petit fichier reste independant du CSV : il survit a un redemarrage,
    -- a un crash ou a plusieurs controles moteur sous le seuil de 5 %.
    if not distance or not distance.hasResult then return false end
    local handle = io.open(config.logPath .. "/lastdistance.txt", "w")
    if not handle then return false end
    local ok = io.write(handle, string.format(
      "MAX_DISTANCE_M=%.1f\nTOTAL_DISTANCE_M=%.1f\n",
      distance.maxMeters or 0, distance.totalMeters or 0))
    io.close(handle)
    return ok ~= nil
  end

  function M.loadLastDistance(distance)
    local handle = io.open(config.logPath .. "/lastdistance.txt", "r")
    if not handle then return end
    local chunks = {}
    while true do
      local data = io.read(handle, 64)
      if not data or #data == 0 then break end
      chunks[#chunks + 1] = data
    end
    io.close(handle)

    local content = table.concat(chunks)
    local maximum = tonumber(string.match(content, "MAX_DISTANCE_M=([%d%.]+)"))
    local total = tonumber(string.match(content, "TOTAL_DISTANCE_M=([%d%.]+)"))
    if maximum and total then
      distance.maxMeters = math.max(0, maximum)
      distance.totalMeters = math.max(0, total)
      distance.hasResult = true
      -- Le point Home n'est pas conserve : ces valeurs restent une sauvegarde
      -- du dernier vol, pas une fausse distance courante apres redemarrage.
      distance.valid = false
    end
  end

  return M
end
