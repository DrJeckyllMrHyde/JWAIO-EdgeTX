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

  local confirmations = {
    arm=true, rth=true, preArm=true, beeper=true, flip=true,
    angle=true, acro=true, satellite=true,
    batteryFullLihv=true, batteryFullStandard=true
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
    if audio.finderActive and confirmations[kind] then return end
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
    if audio.finderActive or #audio.queue == 0 or now < audio.nextPlay then return end
    local kind = table.remove(audio.queue, 1)
    audio.queued[kind] = nil
    local path = fileFor(kind)
    if not path or not playFile then return end
    local ok, result = pcall(playFile, path)
    if not ok or result == false then
      request(audio, kind)
      audio.nextPlay = now + 1
      return
    end
    -- Une alerte en attente n'est pas encore annoncee. Cela permet au Finder
    -- de la differer sans perdre le franchissement, notamment celui des 120 m.
    if kind == "batteryLow" then audio.batteryLow.announced = true end
    if kind == "batteryCritical" then
      audio.batteryCritical.announced = true
      audio.batteryLow.announced = true
    end
    if kind == "altitude" then audio.altitudeAnnounced = true end
    local duration = config.soundDurations and config.soundDurations[kind]
    audio.nextPlay = now + (duration and (duration + (config.audioPaddingSeconds or 0.08))
      or (config.audioGapSeconds or 3.2))
  end

  local function updateBatteryEpisode(audio, episode, kind, valid, value,
      threshold, recover, now, hold)
    if not valid then
      -- Une perte de telemetrie n'est ni une batterie faible ni une recharge.
      episode.since = nil
      episode.recoveredSince = nil
      cancel(audio, kind)
      return
    end
    if value >= recover then
      episode.recoveredSince = episode.recoveredSince or now
      if now - episode.recoveredSince >= (config.batteryRecoverySeconds or 5) then
        resetEpisode(episode)
      end
    else
      episode.recoveredSince = nil
    end
    if value < threshold then
      episode.since = episode.since or now
      if not episode.announced and now - episode.since >= hold then
        request(audio, kind)
      end
    else
      episode.since = nil
      cancel(audio, kind)
    end
  end

  function M.new()
    return {
      queue = {},
      queued = {},
      nextPlay = 0,
      finderActive = false,
      batteryLow = { since=nil, announced=false },
      batteryCritical = { since=nil, announced=false },
      link = { since=nil, announced=false },
      gps = { since=nil, announced=false },
      throttle = { since=nil, announced=false },
      hadGpsFix = false,
      gpsReady = false,
      altitudeAnnounced = false,
      altitudeBaseline = nil,
      groundAltitude = nil,
      groundAltitudeAt = nil,
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

    local wasArmed = audio.previous.armed
    audio.finderActive = state.beeper or state.flip or state.rth or false
    if audio.finderActive then
      -- Les confirmations n'ont plus d'interet apres une recherche. Les alertes
      -- encore pertinentes attendront sa fin ; aucune nouvelle voix ne retarde
      -- les bips. Un WAV deja lance termine sa lecture (pas de purge globale).
      for kind in pairs(confirmations) do cancel(audio, kind) end
    end

    updateBatteryConnection(audio, state, profile, now)
    updateActivationSounds(audio, state)

    local gpsReady = state.gpsState == "GPS OK"
    if not gpsReady then cancel(audio, "satellite") end
    if gpsReady and not audio.gpsReady then request(audio, "satellite") end
    audio.gpsReady = gpsReady
    if gpsReady then audio.hadGpsFix = true end

    local critical = state.batteryValid and state.battery < profile.critical
    updateBatteryEpisode(audio, audio.batteryCritical, "batteryCritical",
      state.batteryValid, state.battery, profile.critical,
      profile.critical + (config.batteryCriticalRecoveryMargin or 0.08), now,
      config.batteryCriticalHoldSeconds or 1.0)
    updateBatteryEpisode(audio, audio.batteryLow, "batteryLow",
      state.batteryValid, state.battery, profile.warn, profile.recover, now,
      config.batteryHoldSeconds or 1.2)
    if critical then
      -- Ne pas jouer une annonce de niveau bas quand le niveau critique est
      -- deja atteint, meme pendant la temporisation anti-sag du critique.
      cancel(audio, "batteryLow")
      audio.batteryLow.since = nil
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

    -- Reference du gain figee au front ARM. Si Alt apparait seulement en vol,
    -- ne pas prendre cette altitude tardive pour le sol et masquer les 120 m.
    if not inFlight then
      if state.altitudeValid then
        audio.groundAltitude = state.altitude
        audio.groundAltitudeAt = now
      end
    elseif wasArmed == false then
      if state.altitudeValid then
        audio.altitudeBaseline = state.altitude
      elseif audio.groundAltitudeAt and now - audio.groundAltitudeAt <= 2.5 then
        audio.altitudeBaseline = audio.groundAltitude
      end
    end
    local altitudeForAlert = nil
    -- Ne pas annoncer plus tard une mesure devenue invalide pendant l'attente.
    if not state.altitudeValid then cancel(audio, "altitude") end
    if state.altitudeValid then
      if config.altitudeReference == "sensor" then
        altitudeForAlert = state.altitude
      elseif audio.altitudeBaseline then
        altitudeForAlert = state.altitude - audio.altitudeBaseline
      end
    end
    if inFlight and not audio.altitudeAnnounced and altitudeForAlert and
       altitudeForAlert > config.altitudeAlertMeters then
      request(audio, "altitude")
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
      cancel(audio, "altitude")
      cancel(audio, "link")
      cancel(audio, "gps")
      cancel(audio, "throttle")
    end

    if not poorLink then cancel(audio, "link") end
    if not gpsLost then cancel(audio, "gps") end
    if not highThrottle then cancel(audio, "throttle") end

    playNext(audio, now)
  end

  function M.playFinderBip(audio, now)
    -- Priorite Finder sur la file JWAIO. Respecter la fin du WAV deja lance
    -- evite d'empiler les sons dans le lecteur EdgeTX partage par la radio.
    if not audio.finderActive or now < audio.nextPlay or not playFile then return false end

    local path = fileFor("finderBip")
    if not path then return false end
    local ok, result = pcall(playFile, path)
    if not ok or result == false then return false end

    -- Reserve seulement la duree approximative du petit bip, contrairement aux
    -- annonces vocales qui utilisent l'espacement general plus long.
    audio.nextPlay = now + (config.finderAudioReserveSeconds or 0.20)
    return true
  end

  return M
end
