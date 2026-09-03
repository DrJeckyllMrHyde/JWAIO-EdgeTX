-- ============================================================================
-- JWAIO - Jeckyll Widget All in One
-- Copyright 2026 DrJeckyllMrHyde
-- SPDX-License-Identifier: Apache-2.0
-- Fichier : lib/data.lua
-- Version : 0.2.1
-- Role    : acquisition et normalisation des commandes et de la telemetrie.
-- ============================================================================

return function(config, util)
  local M = {}

  -- EdgeTX 2.12 expose getSourceValue avec les indicateurs current/fresh.
  -- Le repli getValue conserve la compatibilite avec les sources classiques.
  local function sourceValue(source)
    if source == nil or source == 0 or source == "" then
      return nil, false, false
    end

    if getSourceValue then
      local ok, value, current, fresh = pcall(getSourceValue, source)
      if ok then
        local valid = (current ~= false) and value ~= nil
        return value, valid, fresh ~= false
      end
    end

    local ok, value = pcall(getValue, source)
    if not ok or value == nil then return nil, false, false end
    if type(value) == "number" and value == 0 then return value, false, false end
    return value, true, true
  end

  local function numericSource(source)
    local value, valid, fresh = sourceValue(source)
    if type(value) ~= "number" then return nil, false, fresh end
    return value, valid, fresh
  end

  -- Une option SWITCH contient l'identifiant de la position choisie dans le
  -- menu du widget, et non directement le nom physique du switch.
  local function switchActive(source)
    if source == nil or source == 0 then return false end
    if getSwitchValue then
      local ok, value = pcall(getSwitchValue, source)
      if ok then
        if type(value) == "boolean" then return value end
        if type(value) == "number" then return value > 0 end
      end
    end
    local ok, value = pcall(getValue, source)
    return ok and type(value) == "number" and value > 0
  end

  local function readThrottle(source)
    local ok, value = pcall(getValue, source)
    if not ok or type(value) ~= "number" then return 0 end
    return util.clamp(util.round((value + 1024) * 100 / 2048), 0, 100)
  end

  -- TIMER 1 et TIMER 2 restent les compteurs natifs du modele EdgeTX. Le widget
  -- les affiche sans maintenir un second chronometre concurrent.
  local function timerValue(index)
    if not model or not model.getTimer then return 0, false end
    local ok, timer = pcall(model.getTimer, index)
    if not ok or type(timer) ~= "table" or type(timer.value) ~= "number" then
      return 0, false
    end
    return math.max(0, timer.value), true
  end

  local function demoState(state, now)
    local phase = math.floor(now) % 12
    state.throttle = ({0, 12, 27, 48, 73, 96})[(phase % 6) + 1]
    state.mode = ({"ANGLE", "ACRO", "RTH"})[(math.floor(now / 4) % 3) + 1]
    state.battery = 3.80
    state.batteryValid = true
    state.batteryType = "LiPo"
    state.batteryProfile = config.batteryProfiles[1]
    state.flyTime = 180
    state.flyTimeValid = true
    state.flyTotal = 25200
    state.flyTotalValid = true
    state.lq = 100
    state.lqValid = true
    state.rssi = -78
    state.rssiValid = true
    state.sats = 12
    state.satsValid = true
    state.gpsValid = true
    state.gpsState = "GPS OK"
    state.lat = 48.856613
    state.lon = 2.352222
    state.altitude = 42
    state.altitudeValid = true
    state.speed = 18
    state.speedValid = true
    state.distance = 127
    state.distanceValid = true
    state.totalDistance = 1250
    state.maxDistance = 360
    state.armed = false
    state.prearmed = true
    state.beeper = phase > 8
    state.flip = false
    state.rth = false
    state.linkType = "ELRS"
  end

  function M.new()
    return {
      now = 0,
      throttle = 0,
      mode = "ACRO",
      battery = nil,
      batteryValid = false,
      batteryType = "LiPo",
      batteryProfile = config.batteryProfiles[1],
      flyTime = 0,
      flyTimeValid = false,
      flyTotal = 0,
      flyTotalValid = false,
      lq = nil,
      lqValid = false,
      rssi = nil,
      rssiValid = false,
      sats = nil,
      satsValid = false,
      gpsValid = false,
      gpsState = "NO_DATA",
      nextNavigationUpdate = 0,
      navigationUpdated = false,
      lat = nil,
      lon = nil,
      lastLat = nil,
      lastLon = nil,
      altitude = nil,
      altitudeValid = false,
      speed = nil,
      speedValid = false,
      distance = nil,
      distanceValid = false,
      totalDistance = nil,
      maxDistance = nil,
      armed = false,
      prearmed = false,
      beeper = false,
      flip = false,
      rth = false,
      sources = {
        -- Les identifiants des capteurs fixes sont mis en cache ici une seule
        -- fois. L'utilisateur doit les avoir decouverts avant d'ajouter JWAIO.
        battery = util.sourceIndex(config.batterySource),
        gps = util.sourceIndex(config.gpsSource),
        altitude = util.sourceIndex(config.altitudeSource),
        speed = util.sourceIndex(config.speedSource),
        satellites = util.sourceIndex(config.satellitesSource),
        rssi = util.sourceIndex(config.rssiSource)
      },
      linkType = "ELRS"
    }
  end

  function M.update(state, options)
    -- Les commandes et donnees rapides sont relues a chaque cycle du widget.
    state.now = getTime() / 100
    state.navigationUpdated = false
    state.throttle = readThrottle(util.option(options, "Thr", 0))

    local profileIndex = util.clamp(util.option(options, "BatType", 1), 1, 3)
    state.batteryProfile = config.batteryProfiles[profileIndex] or config.batteryProfiles[1]
    state.batteryType = state.batteryProfile.name
    state.linkType = util.option(options, "LinkType", 1) == 2 and "TBS_CF" or "ELRS"
    state.flyTime, state.flyTimeValid = timerValue(config.flyTimeTimer)
    state.flyTotal, state.flyTotalValid = timerValue(config.flyTotalTimer)

    state.armed = switchActive(util.option(options, "ARM", 0))
    state.prearmed = switchActive(util.option(options, "PreArm", 0))
    state.beeper = switchActive(util.option(options, "Beeper", 0))
    state.flip = switchActive(util.option(options, "Flip", 0))
    state.rth = switchActive(util.option(options, "RTH", 0))

    local modeRaw = 0
    local okMode, modeValue = pcall(getValue, config.modeSource)
    if okMode and type(modeValue) == "number" then modeRaw = modeValue end
    if state.rth then
      state.mode = "RTH"
    elseif modeRaw < config.modeLow then
      state.mode = "ANGLE"
    else
      state.mode = "ACRO"
    end

    local pack, packValid = numericSource(state.sources.battery)
    local cells = math.max(1, util.option(options, "Cells", 6))
    if packValid and pack and pack > 0 then
      if pack <= config.perCellAutoMax then
        state.battery = pack
      else
        state.battery = pack / cells
      end
      state.batteryValid = true
    else
      state.battery = nil
      state.batteryValid = false
    end

    state.lq, state.lqValid = numericSource(util.option(options, "LQ", 0))
    state.rssi, state.rssiValid = numericSource(state.sources.rssi)

    -- La navigation est echantillonnee a 1 Hz, sur la meme base de temps que
    -- le CSV. Le RSSI reste rapide car le Qwad Finder en depend directement.
    if state.now >= state.nextNavigationUpdate then
      state.nextNavigationUpdate = state.now + (config.navigationPeriodSeconds or 1.0)
      state.navigationUpdated = true
      state.sats, state.satsValid = numericSource(state.sources.satellites)

      local gps, gpsCurrent = sourceValue(state.sources.gps)
      state.gpsValid = gpsCurrent and type(gps) == "table" and
        type(gps.lat) == "number" and type(gps.lon) == "number" and
        not (gps.lat == 0 and gps.lon == 0)

      if state.gpsValid then
        state.lat = gps.lat
        state.lon = gps.lon
      else
        state.lat = nil
        state.lon = nil
      end

      local sats = state.sats or 0
      -- Une position devient recuperable a partir de cinq satellites. La
      -- couleur detaillee 1-4/5-7/8+ est geree ensuite par l'interface.
      if state.gpsValid and state.satsValid and sats >= config.gpsReadySatellites then
        state.gpsState = "GPS OK"
        state.lastLat = state.lat
        state.lastLon = state.lon
      elseif state.satsValid and sats >= 1 then
        state.gpsState = "RECHERCHE"
      else
        state.gpsState = "NO_DATA"
      end

      state.altitude, state.altitudeValid = numericSource(state.sources.altitude)
      state.speed, state.speedValid = numericSource(state.sources.speed)
      if state.speedValid then state.speed = state.speed * (config.speedMultiplier or 1) end
    end
    -- Le mode demo est applique en dernier pour remplacer proprement toutes les
    -- valeurs reelles sans multiplier les conditions dans les autres modules.
    if config.demo then demoState(state, state.now) end
    return state
  end

  return M
end
