-- ============================================================================
-- JWAIO - Jeckyll Widget All in One
-- Copyright 2026 DrJeckyllMrHyde
-- SPDX-License-Identifier: Apache-2.0
-- Fichier : lib/ui.lua
-- Version : 0.2.1
-- Role    : rendu plein ecran 480x320 et mise a l'echelle de la zone EdgeTX.
-- ============================================================================

return function(config, util)
  local M = {}
  -- Police XXS disponible sur les ecrans couleur EdgeTX. Elle n'a pas de
  -- constante nommee dans l'API Lua classique, sa valeur de flag est 512.
  local XSMSIZE = 512
  -- Ne jamais remplacer RIGHT par une valeur numerique : la valeur du drapeau
  -- depend de l'implementation EdgeTX. L'ancien 64 n'alignait pas le texte sur
  -- la TX15 et faisait partir NO_DATA vers la droite de chaque colonne.
  local RIGHT_ALIGN = RIGHT

  local C = {
    black = lcd.RGB(0, 0, 0),
    panel = lcd.RGB(9, 11, 14),
    line = lcd.RGB(48, 54, 61),
    white = lcd.RGB(244, 246, 248),
    grey = lcd.RGB(135, 143, 153),
    orange = lcd.RGB(255, 132, 28),
    green = lcd.RGB(126, 190, 38),
    red = lcd.RGB(255, 55, 55),
    blue = lcd.RGB(75, 142, 255)
  }

  local function transform(zone)
    -- Toutes les positions sont dessinees dans un repere fixe 480x320, puis
    -- adaptees a la zone transmise par EdgeTX sans recalculer le layout.
    local sx = zone.w / 480
    local sy = zone.h / 320
    local scale = math.min(sx, sy)
    return {
      scale = scale,
      sx = sx,
      sy = sy,
      x = function(value) return zone.x + math.floor(value * sx + 0.5) end,
      y = function(value) return zone.y + math.floor(value * sy + 0.5) end,
      w = function(value) return math.max(1, math.floor(value * sx + 0.5)) end,
      h = function(value) return math.max(1, math.floor(value * sy + 0.5)) end
    }
  end

  local function panel(t, x, y, w, h, title, accent)
    lcd.drawFilledRectangle(t.x(x), t.y(y), t.w(w), t.h(h), C.panel)
    lcd.drawRectangle(t.x(x), t.y(y), t.w(w), t.h(h), C.line, 1)
    lcd.drawText(t.x(x + 6), t.y(y + 5), title, XSMSIZE + accent)
  end

  local function centered(t, x, y, text, flags, color)
    lcd.drawText(t.x(x), t.y(y), text, (flags or 0) + CENTER + color)
  end

  local function throttleIndex(percent)
    -- Cinq images PNG statiques remplacent toute animation couteuse en CPU.
    if percent < 13 then return 1 end
    if percent < 38 then return 2 end
    if percent < 63 then return 3 end
    if percent < 88 then return 4 end
    return 5
  end

  local function openBitmap(path)
    if not Bitmap or not Bitmap.open then return nil end
    local ok, bitmap = pcall(Bitmap.open, path)
    if not ok then return nil end
    if Bitmap.getSize then
      local w, h = Bitmap.getSize(bitmap)
      if not w or w == 0 or not h or h == 0 then return nil end
    end
    return bitmap
  end

  function M.loadImages()
    -- Seul le logo est charge au demarrage. Les cinq images de throttle sont
    -- chargees a la demande, lors de leur premiere utilisation.
    return {
      logo = openBitmap(config.basePath .. "/img/logo.png"),
      throttle = {}
    }
  end

  local function drawLogo(t, images)
    if images.logo then
      local scale = math.floor(t.scale * 100 + 0.5)
      local x = t.x(241) - math.floor(216 * t.scale / 2)
      if scale == 100 then
        lcd.drawBitmap(images.logo, x, t.y(4))
      else
        lcd.drawBitmap(images.logo, x, t.y(4), scale)
      end
    else
      centered(t, 241, 40, "JWAIO", BOLD, C.white)
      centered(t, 241, 62, "FPV", MIDSIZE, C.white)
    end
  end

  local function drawThrottle(t, images, percent)
    local index = throttleIndex(percent)
    if not images.throttle[index] then
      images.throttle[index] = openBitmap(config.basePath .. "/img/thr" .. tostring(index - 1) .. ".png")
    end
    centered(t, 241, 227, "THROTTLE", XSMSIZE, C.orange)
    centered(t, 241, 242, tostring(percent) .. "%", BOLD, C.white)
    local image = images.throttle[index]
    if image then
      local scale = math.floor(t.scale * 100 + 0.5)
      local x = t.x(241) - math.floor(166 * t.scale / 2)
      if scale == 100 then
        lcd.drawBitmap(image, x, t.y(281))
      else
        lcd.drawBitmap(image, x, t.y(281), scale)
      end
    end
  end

  local function modeColor(mode)
    if mode == "ANGLE" then return C.green end
    if mode == "RTH" then return C.red end
    return C.orange
  end

  local function batteryColor(state)
    if not state.batteryValid then return C.grey end
    local profile = state.batteryProfile or config.batteryProfiles[1]
    if state.battery < profile.critical then return C.red end
    if state.battery < profile.warn then return C.orange end
    return C.green
  end

  local function linkColor(state)
    if not state.lqValid then return C.grey end
    if state.lq < config.lqCritical then return C.red end
    if state.lq < config.lqWarn then return C.orange end
    return C.green
  end

  local function drawLinkGauge(t, state)
    local lq = state.lqValid and util.clamp(state.lq, 0, 100) or 0
    local width = math.floor(102 * lq / 100)
    lcd.drawRectangle(t.x(367), t.y(145), t.w(102), t.h(8), C.line, 1)
    if width > 0 then
      lcd.drawFilledRectangle(t.x(368), t.y(146), t.w(math.max(1, width - 2)), t.h(6), linkColor(state))
    end
  end

  local function batteryTitle(state)
    if state.batteryType == "LiIon" then return "CELL LIION" end
    if state.batteryType == "LiHv" then return "CELL LIHV" end
    return "CELL LIPO"
  end

  local function drawMetric(t, labelX, valueX, y, label, value, valid)
    -- Deux colonnes alignees remplacent un tableau ou des cadres supplementaires.
    lcd.drawText(t.x(labelX), t.y(y), label, XSMSIZE + C.orange)
    lcd.drawText(t.x(valueX), t.y(y), value,
      XSMSIZE + RIGHT_ALIGN + (valid and C.white or C.grey))
  end

  local function drawFlightMetrics(t, state)
    -- GPS OK est exige pour les quatre valeurs. Les compteurs internes ne sont
    -- pas effaces pendant une perte : seule leur presentation passe a NO_DATA.
    local gpsReady = state.gpsState == "GPS OK"
    local speedValid = gpsReady and state.speedValid
    local altitudeValid = gpsReady and state.altitudeValid
    local distanceValid = gpsReady and state.distanceValid

    local speed = speedValid and string.format("%.1f km/h", state.speed) or "NO_DATA"
    local altitude = altitudeValid and string.format("%.0f m", state.altitude) or "NO_DATA"
    local distance = distanceValid and string.format("%.3f km", state.distance / 1000) or "NO_DATA"
    local total = distanceValid and string.format("%.2f km", state.totalDistance / 1000) or "NO_DATA"

    drawMetric(t, 132, 236, 184, "Speed", speed, speedValid)
    drawMetric(t, 248, 350, 184, "Alt", altitude, altitudeValid)
    drawMetric(t, 132, 236, 203, "Dist", distance, distanceValid)
    drawMetric(t, 248, 350, 203, "Total", total, distanceValid)
  end

  local function satelliteDisplay(state)
    if not state.satsValid or not state.sats or state.sats < 1 then
      return "NO_DATA", C.grey
    end
    local count = util.round(state.sats)
    if count <= 4 then return "SAT " .. tostring(count), C.red end
    if count <= 7 then return "SAT " .. tostring(count), C.orange end
    return "SAT " .. tostring(count), C.green
  end

  local function finderColor(strength)
    -- Ici la couleur signifie eloignement estime, pas qualite de liaison en vol.
    if strength < 35 then return C.red end
    if strength < 70 then return C.orange end
    return C.green
  end

  local function drawFinderGauge(t, finder)
    local strength = finder and finder.valid and util.clamp(finder.strength, 0, 100) or 0
    local inside = math.floor(110 * strength / 100)
    lcd.drawRectangle(t.x(362), t.y(292), t.w(112), t.h(8), C.line, 1)
    if inside > 0 then
      lcd.drawFilledRectangle(t.x(363), t.y(293), t.w(inside), t.h(6), finderColor(strength))
    end
    lcd.drawText(t.x(362), t.y(303), "0%", XSMSIZE + C.grey)
    lcd.drawText(t.x(474), t.y(303), "100%", XSMSIZE + RIGHT_ALIGN + C.grey)
  end

  local function drawFinder(t, widget)
    panel(t, 356, 256, 124, 64, "QWAD FINDER", C.green)

    local requested = widget.data.beeper or widget.data.flip or widget.data.rth
    if not requested then
      centered(t, 418, 281, "OFF", SMLSIZE, C.grey)
      centered(t, 418, 303, "B / F / RTH", XSMSIZE, C.grey)
      return
    end

    if widget.finderLoadError then
      centered(t, 418, 283, "MODULE ERROR", XSMSIZE, C.red)
      return
    end

    local finder = widget.finder
    if not finder or not finder.valid then
      lcd.drawText(t.x(362), t.y(276), "RSSI", XSMSIZE + C.grey)
      lcd.drawText(t.x(474), t.y(276), "NO_DATA", XSMSIZE + RIGHT_ALIGN + C.grey)
      drawFinderGauge(t, finder)
      return
    end

    lcd.drawText(t.x(362), t.y(276), finder.source, XSMSIZE + C.grey)
    lcd.drawText(t.x(474), t.y(276),
      tostring(finder.value) .. " " .. finder.unit,
      XSMSIZE + RIGHT_ALIGN + C.white)
    drawFinderGauge(t, finder)
  end

  function M.draw(widget)
    local zone = widget.zone
    local t = transform(zone)
    local state = widget.data
    local flight = widget.flight

    lcd.drawFilledRectangle(zone.x, zone.y, zone.w, zone.h, C.black)

    if zone.w < 360 or zone.h < 220 then
      centered(t, 240, 135, "JWAIO", BOLD, C.orange)
      centered(t, 240, 160, "UTILISER UNE ZONE PLEIN ECRAN", XSMSIZE, C.white)
      return
    end

    panel(t, 0, 0, 124, 55, "MODE DE VOL", C.orange)
    centered(t, 62, 28, state.mode, BOLD, modeColor(state.mode))

    panel(t, 0, 57, 124, 51, "FLY TIME", C.orange)
    centered(t, 62, 80, util.formatFlightTime(flight.flightSeconds), BOLD, C.white)

    panel(t, 0, 110, 124, 52, "FLY TOTAL", C.orange)
    centered(t, 62, 136, util.formatTotalTime(flight.totalSeconds), SMLSIZE, C.white)

    panel(t, 0, 206, 124, 48, "GPS", C.blue)
    local satelliteText, satelliteColor = satelliteDisplay(state)
    centered(t, 62, 226, satelliteText, BOLD, satelliteColor)

    panel(t, 0, 256, 124, 64, "DERNIERE POSITION", C.blue)
    if state.lastLat and state.lastLon then
      lcd.drawText(t.x(7), t.y(280), string.format("LAT %.5f", state.lastLat), XSMSIZE + C.white)
      lcd.drawText(t.x(7), t.y(297), string.format("LON %.5f", state.lastLon), XSMSIZE + C.white)
    else
      centered(t, 62, 286, "N/A", BOLD, C.grey)
    end

    panel(t, 356, 0, 124, 55, batteryTitle(state), C.orange)
    local batteryText = state.batteryValid and string.format("%.2fV", state.battery) or "NO_DATA"
    centered(t, 418, 28, batteryText, BOLD, batteryColor(state))

    panel(t, 356, 57, 124, 105, state.linkType or "ELRS", C.green)
    local lqText = state.lqValid and tostring(util.round(state.lq)) .. "%" or "NO_DATA"
    lcd.drawText(t.x(365), t.y(84), "LQ", XSMSIZE + C.grey)
    centered(t, 426, 80, lqText, SMLSIZE, linkColor(state))
    if state.rssiValid then
      lcd.drawText(t.x(365), t.y(114), "RSSI", XSMSIZE + C.grey)
      centered(t, 426, 110, tostring(util.round(state.rssi)) .. " dBm", XSMSIZE, C.white)
    else
      centered(t, 426, 110, "NO_DATA", XSMSIZE, C.grey)
    end
    drawLinkGauge(t, state)

    panel(t, 356, 206, 124, 48, "BEEPER / FLIP", C.orange)
    lcd.drawText(t.x(365), t.y(231), "B " .. (state.beeper and "ON" or "OFF"), SMLSIZE + (state.beeper and C.green or C.grey))
    lcd.drawText(t.x(421), t.y(231), "F " .. (state.flip and "ON" or "OFF"), SMLSIZE + (state.flip and C.red or C.grey))

    drawFinder(t, widget)

    drawLogo(t, widget.images)
    drawThrottle(t, widget.images, state.throttle)

    if widget.logger.active then
      centered(t, 241, 143, "REC", XSMSIZE, C.red)
    elseif widget.logger.error then
      centered(t, 241, 143, widget.logger.error, XSMSIZE, C.red)
    end

    -- RTH/Pre-Arm/Arm restent independants du Qwad Finder : l'etat central
    -- continue de representer uniquement la preparation et l'armement du vol.
    local status = state.armed and "Arm" or (state.prearmed and "Pre-Arm" or "Ready")
    centered(t, 241, 157, status, BOLD, state.armed and C.red or (state.prearmed and C.orange or C.green))
    drawFlightMetrics(t, state)
  end

  return M
end
