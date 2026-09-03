-- ============================================================================
-- JWAIO - Jeckyll Widget All in One
-- Copyright 2026 DrJeckyllMrHyde
-- SPDX-License-Identifier: Apache-2.0
-- Fichier : lib/logger.lua
-- Version : 0.2.1
-- Role    : journal CSV a 1 Hz et conservation de la derniere position GPS.
-- ============================================================================

return function(config, util)
  local M = {}

  local function numberOrBlank(value, precision)
    if type(value) ~= "number" then return "" end
    return string.format("%." .. tostring(precision or 2) .. "f", value)
  end

  local function fileExists(path)
    local handle = io.open(path, "r")
    if not handle then return false end
    io.close(handle)
    return true
  end

  local function newLogFilename()
    local base = config.logPath .. "/F" .. util.fileStamp()
    local filename = base .. ".csv"
    if not fileExists(filename) then return filename end
    -- Le suffixe empeche deux armements pendant la meme seconde d'ecraser le
    -- meme vol. La recherche reste volontairement bornee a 99 collisions.
    for index = 1, 99 do
      filename = string.format("%s_%02d.csv", base, index)
      if not fileExists(filename) then return filename end
    end
    return base .. "_99.csv"
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
    logger.filename = newLogFilename()
    local handle = io.open(logger.filename, "w")
    if not handle then
      logger.error = "LOG OPEN"
      logger.active = false
      return false
    end
    local ok = io.write(handle,
      "date,time,lat,lon,altitude,speed,cell_v,distance_home_m,distance_total_m,distance_max_m,lq,sats\n")
    io.close(handle)
    if not ok then
      logger.error = "LOG WRITE"
      logger.active = false
      return false
    end
    logger.active = true
    logger.nextWrite = now
    logger.error = nil
    return true
  end

  function M.stop(logger)
    logger.active = false
    logger.nextWrite = 0
  end

  function M.update(logger, state)
    if not logger.active or not logger.filename then return end
    if state.now < logger.nextWrite then return end

    local line = table.concat({
      util.dateText(),
      util.timeText(),
      numberOrBlank(state.lat, 7),
      numberOrBlank(state.lon, 7),
      numberOrBlank(state.altitude, 1),
      numberOrBlank(state.speed, 1),
      numberOrBlank(state.battery, 2),
      numberOrBlank(state.distance, 1),
      numberOrBlank(state.totalDistance, 1),
      numberOrBlank(state.maxDistance, 1),
      numberOrBlank(state.lq, 0),
      numberOrBlank(state.sats, 0)
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
    -- Conserver aussi la derniere position a chaque echantillon GPS/CSV pour
    -- qu'une coupure d'alimentation ne perde pas la fin du vol.
    M.saveLastPosition(state)
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
