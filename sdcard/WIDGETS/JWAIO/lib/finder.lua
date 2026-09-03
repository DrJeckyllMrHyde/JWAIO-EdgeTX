-- ============================================================================
-- JWAIO - Jeckyll Widget All in One
-- Copyright 2026 DrJeckyllMrHyde
-- SPDX-License-Identifier: Apache-2.0
-- Fichier : lib/finder.lua
-- Version : 0.2.1
-- Cible   : RadioMaster TX15 Max / EdgeTX 2.12.x
-- Role    : Qwad Finder directionnel base sur la puissance du signal recu.
--
-- Principe adapte de ELRS_Finder.lua par Sunil Chahal (licence MIT) :
-- https://github.com/iamsunilchahal/edgetx-lua-scripts-bw
-- Le code d'affichage B/W et playTone ne sont pas repris. JWAIO conserve
-- uniquement le lissage du signal et le rapprochement progressif des bips.
-- ============================================================================

return function(config, util)
  -- Cette table est l'instance complete du finder. main.lua la passe a nil des
  -- que Beeper, Flip et RTH sont tous inactifs, permettant sa collecte memoire.
  local finder = {
    valid = false,
    source = "RSSI",
    value = nil,
    unit = "dBm",
    filtered = nil,
    strength = 0,
    nextBeep = 0
  }

  local function smoothing(previous, current)
    if previous == nil then return current end
    local alpha = util.clamp(config.finderFilterAlpha or 0.20, 0.01, 1.00)
    return previous * (1 - alpha) + current * alpha
  end

  local function clearSignal(self, now)
    self.valid = false
    self.value = nil
    self.filtered = nil
    self.strength = 0
    -- Autoriser un bip immediat lorsque la telemetrie reviendra.
    self.nextBeep = now
  end

  local function readSignal(state)
    -- 1RSS est la meilleure information directionnelle : une valeur moins
    -- negative indique en general que la radio pointe/se rapproche du quad.
    if state.rssiValid and type(state.rssi) == "number" and state.rssi ~= 0 then
      return state.rssi, "RSSI", "dBm"
    end

    -- Repli issu du finder d'origine : RQly permet encore une jauge quand le
    -- RSSI dBm n'est pas disponible. Il est moins precis pres de 100 %.
    if state.lqValid and type(state.lq) == "number" then
      return util.clamp(state.lq, 0, 100), "LQ", "%"
    end

    return nil, "RSSI", "dBm"
  end

  local function normalizedStrength(value, source)
    if source == "LQ" then return util.clamp(value, 0, 100) end

    local minimum = config.finderRssiMinimum or -110
    local maximum = config.finderRssiMaximum or -40
    if maximum <= minimum then return 0 end
    return util.clamp((value - minimum) * 100 / (maximum - minimum), 0, 100)
  end

  local function beepPeriod(strength)
    local far = config.finderFarSeconds or 2.00
    local near = config.finderNearSeconds or 0.65
    if far < near then far, near = near, far end
    return far - (far - near) * util.clamp(strength, 0, 100) / 100
  end

  function finder:update(state, tryBeep)
    local now = state.now or 0
    local raw, source, unit = readSignal(state)
    if raw == nil then
      clearSignal(self, now)
      return
    end

    -- Une bascule RSSI/LQ remet le filtre a zero : les deux sources n'utilisent
    -- pas la meme echelle et ne doivent jamais etre melangees.
    if source ~= self.source then self.filtered = nil end
    self.source = source
    self.unit = unit
    self.filtered = smoothing(self.filtered, raw)
    self.value = util.round(self.filtered)
    self.strength = normalizedStrength(self.filtered, source)
    self.valid = true

    -- Ne decaler l'echeance que si le gestionnaire audio a reellement accepte
    -- le bip. Une alerte batterie/GPS prioritaire peut donc le repousser sans le
    -- perdre et sans superposer deux fichiers WAV.
    if now >= self.nextBeep and tryBeep and tryBeep() then
      self.nextBeep = now + beepPeriod(self.strength)
    end
  end

  return finder
end
