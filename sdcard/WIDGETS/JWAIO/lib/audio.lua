-- ============================================================================
-- JWAIO - Jeckyll Widget All in One
-- Copyright 2026 DrJeckyllMrHyde
-- SPDX-License-Identifier: Apache-2.0
-- Fichier : lib/audio.lua
-- Version : 0.2.1
-- Role    : alertes vocales prioritaires et arbitrage des bips Qwad Finder.
-- ============================================================================

return function(config)
  local M = {}

  -- Plus la valeur est basse, plus l'annonce est prioritaire.
  local priorities = {
    batteryCritical = 1,
    link = 2,
    gps = 3,
    arm = 4,
    rth = 5,
    altitude = 6,
    throttle = 7,
    batteryLow = 8,
    satellite = 9,
    batteryFullLihv = 10,
    batteryFullStandard = 10,
    preArm = 11,
    beeper = 12,
    flip = 13,
    angle = 14,
    acro = 14
  }

  local function fileFor(kind)
    local base = config.sounds[kind]
    if not base then return nil end
    return config.soundPath .. "/" .. base .. config.audioExtension
  end

  local function resetEpisode(episode)
    episode.since = nil
    episode.announced = false
  end

  local function updateEpisode(episode, active, now, hold)
    if not active then
      resetEpisode(episode)
      return false
    end
    if not episode.since then episode.since = now end
    return (now - episode.since) >= hold
  end

  local function request(audio, kind)
    -- Une annonce deja en attente n'est jamais ajoutee une seconde fois. Le tri
    -- maintient les alertes critiques devant les confirmations de switches.
    if not priorities[kind] or not fileFor(kind) or audio.queued[kind] then return end
    audio.queue[#audio.queue + 1] = kind
    audio.queued[kind] = true
    table.sort(audio.queue, function(left, right)
      return priorities[left] < priorities[right]
    end)
  end

  local function cancel(audio, kind)
    if not audio.queued[kind] then return end
    for index, queuedKind in ipairs(audio.queue) do
      if queuedKind == kind then
        table.remove(audio.queue, index)
        break
      end
    end
    audio.queued[kind] = nil
  end

  local function rising(previous, current)
    return previous == false and current == true
  end

  local function updateBatteryConnection(audio, state, profile, now)
    -- Une disparition breve de la telemetrie est consideree comme une coupure
    -- radio, pas comme le branchement d'une nouvelle batterie pleine.
    if state.batteryValid then
      if not audio.batteryConnected then
        if profile.full and state.battery > profile.full then
          request(audio, profile.fullSound)
        end
        audio.batteryConnected = true
      end
      audio.batteryMissingSince = nil
      return
    end

    if not audio.batteryConnected then return end
    if not audio.batteryMissingSince then
      audio.batteryMissingSince = now
    elseif (now - audio.batteryMissingSince) >= config.batteryReconnectSeconds then
      audio.batteryConnected = false
      audio.batteryMissingSince = nil
    end
  end

  local function updateActivationSounds(audio, state)
    if not audio.initialized then
      audio.initialized = true
    else
      if state.mode ~= audio.previous.mode then
        if state.mode == "ANGLE" then request(audio, "angle") end
        if state.mode == "ACRO" then request(audio, "acro") end
      end
      if rising(audio.previous.armed, state.armed) then request(audio, "arm") end
      if rising(audio.previous.prearmed, state.prearmed) then request(audio, "preArm") end
      if rising(audio.previous.beeper, state.beeper) then request(audio, "beeper") end
      if rising(audio.previous.flip, state.flip) then request(audio, "flip") end
      if rising(audio.previous.rth, state.rth) then request(audio, "rth") end
    end

    audio.previous.mode = state.mode
    audio.previous.armed = state.armed
    audio.previous.prearmed = state.prearmed
    audio.previous.beeper = state.beeper
    audio.previous.flip = state.flip
    audio.previous.rth = state.rth
  end

  local function playNext(audio, now)
    if #audio.queue == 0 or now < audio.nextPlay then return end
    local kind = table.remove(audio.queue, 1)
    audio.queued[kind] = nil
    local path = fileFor(kind)
    if path and playFile then pcall(playFile, path) end
    audio.nextPlay = now + (config.audioGapSeconds or 3.2)
  end

  function M.new()
    return {
      queue = {},
      queued = {},
      nextPlay = 0,
      batteryLowNext = 0,
      batteryLow = { since=nil, announced=false },
      batteryCritical = { since=nil, announced=false },
      link = { since=nil, announced=false },
      gps = { since=nil, announced=false },
      throttle = { since=nil, announced=false },
      hadGpsFix = false,
      gpsReady = false,
      altitudeAnnounced = false,
      altitudeBaseline = nil,
      batteryConnected = false,
      batteryMissingSince = nil,
      initialized = false,
      previous = {
        mode=nil, armed=nil, prearmed=nil, beeper=nil, flip=nil, rth=nil
      }
    }
  end

  function M.update(audio, state)
    local now = state.now
    local inFlight = state.armed
    local profile = state.batteryProfile or config.batteryProfiles[1]

    updateBatteryConnection(audio, state, profile, now)
    updateActivationSounds(audio, state)

    local gpsReady = state.gpsState == "GPS OK"
    if gpsReady and not audio.gpsReady then request(audio, "satellite") end
    audio.gpsReady = gpsReady
    if gpsReady then audio.hadGpsFix = true end

    local critical = state.batteryValid and state.battery < profile.critical
    local low = state.batteryValid and state.battery < profile.warn and not critical

    if updateEpisode(audio.batteryCritical, critical, now,
       config.batteryCriticalHoldSeconds or 1.0) and
       not audio.batteryCritical.announced then
      cancel(audio, "batteryLow")
      request(audio, "batteryCritical")
      audio.batteryCritical.announced = true
    end

    if updateEpisode(audio.batteryLow, low, now, config.batteryHoldSeconds) then
      if now >= audio.batteryLowNext then
        request(audio, "batteryLow")
        audio.batteryLowNext = now + config.batteryRepeatSeconds
      end
    elseif state.batteryValid and state.battery >= profile.recover then
      audio.batteryLowNext = 0
    end

    local poorLink = inFlight and state.lqValid and state.lq < config.lqWarn
    if updateEpisode(audio.link, poorLink, now, config.linkHoldSeconds) and
       not audio.link.announced then
      request(audio, "link")
      audio.link.announced = true
    end
    if state.lqValid and state.lq >= config.lqRecover then resetEpisode(audio.link) end

    local gpsLost = inFlight and audio.hadGpsFix and not gpsReady
    if updateEpisode(audio.gps, gpsLost, now, config.gpsLostHoldSeconds) and
       not audio.gps.announced then
      request(audio, "gps")
      audio.gps.announced = true
    end

    -- Le capteur Alt teste donne une altitude absolue. La limite de 120 m est
    -- donc appliquee au gain depuis l'armement pour eviter une alerte au sol.
    if inFlight and not audio.altitudeBaseline and state.altitudeValid then
      audio.altitudeBaseline = state.altitude
    end
    local altitudeGain = nil
    if state.altitudeValid and audio.altitudeBaseline then
      altitudeGain = state.altitude - audio.altitudeBaseline
    end
    if inFlight and not audio.altitudeAnnounced and altitudeGain and
       altitudeGain > config.altitudeAlertMeters then
      request(audio, "altitude")
      audio.altitudeAnnounced = true
    end

    local highThrottle = inFlight and state.throttle >= config.throttleAlertPercent
    if updateEpisode(audio.throttle, highThrottle, now, config.throttleAlertSeconds) and
       not audio.throttle.announced then
      request(audio, "throttle")
      audio.throttle.announced = true
    end
    if state.throttle <= config.throttleResetPercent then resetEpisode(audio.throttle) end

    if not inFlight then
      resetEpisode(audio.link)
      resetEpisode(audio.gps)
      resetEpisode(audio.throttle)
      audio.hadGpsFix = gpsReady
      audio.altitudeAnnounced = false
      audio.altitudeBaseline = nil
    end

    playNext(audio, now)
  end

  function M.playFinderBip(audio, now)
    -- Les bips de recherche sont auxiliaires : ils ne sont acceptes que lorsque
    -- la file d'alertes est vide et que le lecteur audio est disponible.
    if #audio.queue > 0 or now < audio.nextPlay or not playFile then return false end

    local path = fileFor("finderBip")
    if not path then return false end
    local ok = pcall(playFile, path)
    if not ok then return false end

    -- Reserve seulement la duree approximative du petit bip, contrairement aux
    -- annonces vocales qui utilisent l'espacement general plus long.
    audio.nextPlay = now + (config.finderAudioReserveSeconds or 0.60)
    return true
  end

  return M
end
