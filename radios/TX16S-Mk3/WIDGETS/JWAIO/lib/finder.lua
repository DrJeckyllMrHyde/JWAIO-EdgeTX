-- ============================================================================
-- JWAIO - Jeckyll Widget All in One
-- Copyright 2026 DrJeckyllMrHyde
-- SPDX-License-Identifier: Apache-2.0
-- Fichier : lib/finder.lua
-- Version : 0.3.1 Alpha
-- Cible   : RadioMaster TX16S Mk3 / EdgeTX 2.12.0 ou superieur (essais physiques requis)
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
    nextBeep = 0,
    lastBeep = nil,
    lastUpdate = nil
  }

  local function smoothing(previous, current, dt)
    if previous == nil then return current end
    -- Une constante de temps de 100 ms rend le filtre reactif sans dependre
    -- du nombre d'appels refresh/background par seconde.
    local tau = math.max(0.01, config.finderFilterSeconds or 0.10)
    local alpha = 1 - math.exp(-math.max(0, dt) / tau)
    return previous * (1 - alpha) + current * alpha
  end

  local function clearSignal(self, now)
    self.valid = false
    self.value = nil
    self.filtered = nil
    self.strength = 0
    -- Autoriser un bip immediat lorsque la telemetrie reviendra.
    self.nextBeep = now
    self.lastBeep = nil
    self.lastUpdate = nil
    self.period = nil
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
    local far = config.finderFarSeconds or 1.20
    local near = config.finderNearSeconds or 0.20
    if far < near then far, near = near, far end
    local remaining = 1 - util.clamp(strength, 0, 100) / 100
    return math.max(config.finderAudioReserveSeconds or 0.20,
      near + (far - near) * remaining * remaining)
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
    local dt = self.lastUpdate and now - self.lastUpdate or 0
    self.filtered = smoothing(self.filtered, raw, dt)
    self.lastUpdate = now
    self.value = util.round(self.filtered)
    self.strength = normalizedStrength(self.filtered, source)
    self.valid = true

    -- Recalculer l'echeance a partir du dernier bip accepte : une hausse du
    -- signal raccourcit immediatement l'attente programmee lorsque l'on etait
    -- loin. Aucun rattrapage en rafale si EdgeTX appelle le widget moins vite.
    local period = beepPeriod(self.strength)
    self.period = period
    self.nextBeep = self.lastBeep and (self.lastBeep + period) or now
    if now >= self.nextBeep and tryBeep and tryBeep() then
      self.lastBeep = now
      self.nextBeep = now + period
    end
  end

  return finder
end
