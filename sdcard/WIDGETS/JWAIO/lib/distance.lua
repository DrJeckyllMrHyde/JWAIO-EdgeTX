-- ============================================================================
-- JWAIO - Jeckyll Widget All in One
-- Copyright 2026 DrJeckyllMrHyde
-- SPDX-License-Identifier: Apache-2.0
-- Fichier : lib/distance.lua
-- Version : 0.2.1
-- Cible   : RadioMaster TX15 Max / EdgeTX 2.12.x
-- Role    : distance au point Home, maximum et trajet total du vol courant.
-- ============================================================================

return function(config, util, loggerModule)
  local M = {}
  local RAD = math.pi / 180

  local function gpsUsable(state)
    return state.gpsValid and state.satsValid and
      (state.sats or 0) >= (config.gpsReadySatellites or 5) and
      type(state.lat) == "number" and type(state.lon) == "number"
  end

  -- Distance orthodromique horizontale entre deux coordonnees. A l'echelle
  -- d'un vol FPV, la formule de Haversine offre une precision largement
  -- suffisante sans exiger de capteur Dist calcule dans EdgeTX.
  local function haversine(lat1, lon1, lat2, lon2)
    local dLat = (lat2 - lat1) * RAD
    local dLon = (lon2 - lon1) * RAD
    local sinLat = math.sin(dLat / 2)
    local sinLon = math.sin(dLon / 2)
    local a = sinLat * sinLat +
      math.cos(lat1 * RAD) * math.cos(lat2 * RAD) * sinLon * sinLon
    local angle = 2 * math.asin(math.min(1, math.sqrt(math.max(0, a))))
    return (config.distanceEarthRadiusMeters or 6371000) * angle
  end

  local function resetCurrentFlight(distance)
    distance.active = true
    distance.homeLat = nil
    distance.homeLon = nil
    distance.previousLat = nil
    distance.previousLon = nil
    distance.previousSampleTime = nil
    distance.currentMeters = 0
    distance.maxMeters = 0
    distance.totalMeters = 0
    distance.valid = false
    distance.hasResult = false
    distance.nextSave = 0
  end

  local function clearLiveSample(distance)
    distance.valid = false
    distance.previousLat = nil
    distance.previousLon = nil
    distance.previousSampleTime = nil
  end

  local function sample(distance, state)
    if not gpsUsable(state) then
      clearLiveSample(distance)
      return
    end

    local now = state.now or 0
    if not distance.homeLat then
      -- Le premier point GPS valide du vrai vol devient le Home. Dans le cas
      -- normal il est disponible au premier passage du throttle au-dessus de 5 %.
      distance.homeLat = state.lat
      distance.homeLon = state.lon
      distance.previousLat = state.lat
      distance.previousLon = state.lon
      distance.previousSampleTime = now
      distance.currentMeters = 0
      distance.valid = true
      distance.hasResult = true
      return
    end

    local elapsed = distance.previousSampleTime and
      (now - distance.previousSampleTime) or nil
    local segment = nil
    if distance.previousLat and distance.previousLon then
      segment = haversine(distance.previousLat, distance.previousLon,
        state.lat, state.lon)
    end

    -- Rejeter un saut GPS impossible avant qu'il ne pollue le maximum ou le
    -- total. Le point precedent reste intact pour accepter le retour a la normale.
    if elapsed and elapsed > 0 and segment then
      local limit = (config.distanceMaximumSpeedKmh or 400) / 3.6 * elapsed +
        (config.distanceJumpMarginMeters or 30)
      if segment > limit then
        distance.valid = false
        distance.previousSampleTime = now
        return
      end
    end

    distance.currentMeters = haversine(distance.homeLat, distance.homeLon,
      state.lat, state.lon)
    distance.maxMeters = math.max(distance.maxMeters, distance.currentMeters)

    -- GSpd integre mieux les courbes qu'une simple corde entre deux positions
    -- espacees d'une seconde. La distance GPS entre echantillons reste le repli.
    if elapsed and elapsed > 0 and
       elapsed <= (config.distanceMaximumSampleGapSeconds or 2.5) then
      if state.speedValid and type(state.speed) == "number" and
         state.speed >= 0 and state.speed <= (config.distanceMaximumSpeedKmh or 400) then
        -- La petite vitesse residuelle du GPS au sol (0,4 km/h observe lors
        -- des essais) est ignoree pour ne pas inventer des metres a l'arret.
        if state.speed >= (config.distanceMinimumSpeedKmh or 1.0) then
          distance.totalMeters = distance.totalMeters + state.speed / 3.6 * elapsed
        end
      elseif segment and segment >= (config.distanceMinimumSegmentMeters or 1.0) then
        distance.totalMeters = distance.totalMeters + segment
      end
    end

    distance.previousLat = state.lat
    distance.previousLon = state.lon
    distance.previousSampleTime = now
    distance.valid = true
    distance.hasResult = true
  end

  local function publish(distance, state)
    local visible = distance.valid and state.gpsState == "GPS OK"
    state.distanceValid = visible
    state.distance = visible and distance.currentMeters or nil
    state.totalDistance = visible and distance.totalMeters or nil
    state.maxDistance = visible and distance.maxMeters or nil
  end

  function M.new()
    return {
      active = false,
      previousFlying = false,
      homeLat = nil,
      homeLon = nil,
      previousLat = nil,
      previousLon = nil,
      previousSampleTime = nil,
      currentMeters = 0,
      maxMeters = 0,
      totalMeters = 0,
      valid = false,
      hasResult = false,
      nextSave = 0
    }
  end

  function M.update(distance, state, flight)
    if config.demo and not flight.flying then
      distance.currentMeters = 250
      distance.maxMeters = 360
      distance.totalMeters = 1250
      distance.valid = true
      state.gpsState = "GPS OK"
      publish(distance, state)
      return
    end

    local started = flight.flying and not distance.previousFlying
    local stopped = not flight.flying and distance.previousFlying

    if started then
      -- Double securite : conserver le vol precedent juste avant la seule
      -- operation susceptible de remettre ses compteurs a zero.
      if distance.hasResult then loggerModule.saveLastDistance(distance) end
      resetCurrentFlight(distance)
      sample(distance, state)
    elseif flight.flying and state.navigationUpdated then
      sample(distance, state)
    elseif not flight.flying and state.navigationUpdated and not gpsUsable(state) then
      distance.valid = false
    end

    if flight.flying and distance.hasResult and state.navigationUpdated and
       (state.now or 0) >= distance.nextSave then
      loggerModule.saveLastDistance(distance)
      distance.nextSave = (state.now or 0) + (config.distanceSavePeriodSeconds or 1)
    end

    if stopped then
      distance.active = false
      loggerModule.saveLastDistance(distance)
    end

    publish(distance, state)
    distance.previousFlying = flight.flying
  end

  return M
end
