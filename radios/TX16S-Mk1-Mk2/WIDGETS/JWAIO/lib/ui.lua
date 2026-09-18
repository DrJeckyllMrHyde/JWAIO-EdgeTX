-- ============================================================================
-- JWAIO - Jeckyll Widget All in One
-- Copyright 2026 DrJeckyllMrHyde
-- SPDX-License-Identifier: Apache-2.0
-- Fichier : lib/ui.lua
-- Version : 0.3.1 Alpha - port TX16S Mk1/Mk2
-- Role    : rendu plein ecran 480x272 et mise a l'echelle de la zone EdgeTX.
-- ============================================================================

return function(config, util)
  local M = {}
  -- Constante XXS exposee par EdgeTX 2.12 sur les ecrans couleur.
  local XSMSIZE = TINSIZE
  -- Ne jamais remplacer RIGHT par une valeur numerique : la valeur du drapeau
  -- depend de l'implementation EdgeTX. L'ancien 64 n'alignait pas le texte sur
  -- la TX15 et faisait partir NO_DATA vers la droite de chaque colonne.
  local RIGHT_ALIGN = RIGHT

  local palette = config.palette or {}

  local function themeColor(name, fallback)
    local value = palette[name]
    if type(value) == "table" and #value >= 3 then
      return lcd.RGB(value[1], value[2], value[3])
    end
    return lcd.RGB(fallback[1], fallback[2], fallback[3])
  end

  -- Les couleurs de fonction conservent des noms stables dans tout le rendu.
  -- Chaque manifeste peut ainsi changer l'identite visuelle sans modifier la
  -- logique d'alerte, les seuils ou les positions des informations.
  local C = {
    black = themeColor("black", {0, 0, 0}),
    panel = themeColor("panel", {9, 11, 14}),
    line = themeColor("line", {48, 54, 61}),
    white = themeColor("white", {244, 246, 248}),
    grey = themeColor("grey", {135, 143, 153}),
    orange = themeColor("orange", {255, 132, 28}),
    green = themeColor("green", {126, 190, 38}),
    red = themeColor("red", {255, 55, 55}),
    blue = themeColor("blue", {75, 142, 255})
  }

  local function transform(zone)
    -- Toutes les positions sont dessinees dans un repere fixe 480x272, puis
    -- adaptees a la zone transmise par EdgeTX sans recalculer le layout.
    local sx = zone.w / 480
    local sy = zone.h / 272
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
    -- Certains skins integrent leurs aplats noirs directement dans le PNG :
    -- eviter alors un second remplissage opaque qui masquerait le decor.
    if not config.backgroundIncludesPanels then
      lcd.drawFilledRectangle(t.x(x), t.y(y), t.w(w), t.h(h), C.panel)
    end
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
    if not ok or not bitmap then return nil end
    if Bitmap.getSize then
      local sized, w, h = pcall(Bitmap.getSize, bitmap)
      if not sized or not w or w == 0 or not h or h == 0 then return nil end
    end
    return bitmap
  end

  function M.loadImages()
    -- Seuls le fond et le logo du skin actif sont charges. Les cinq images de
    -- throttle partagees restent chargees a la demande.
    local skinPath = config.skinPath or (config.basePath .. "/img")
    local logo = openBitmap(skinPath .. "/" .. (config.logoImage or "logo.png"))
    local background = openBitmap(skinPath .. "/" .. (config.backgroundImage or "background.png"))
    return {
      logo = logo,
      background = background,
      -- Bitmap.open renvoie un bitmap 0x0 en cas de fichier invalide ou de
      -- memoire insuffisante. openBitmap le convertit en nil et ce drapeau
      -- rend enfin le probleme visible a l'ecran.
      backgroundError = background == nil,
      throttle = {}
    }
  end

  local function drawBackground(t, widget)
    local image = widget.images.background
    -- Nettoyer toute la zone garantit un rendu propre meme si EdgeTX fournit
    -- exceptionnellement une zone dont le ratio differe du plein ecran.
    lcd.drawFilledRectangle(widget.zone.x, widget.zone.y, widget.zone.w, widget.zone.h, C.black)
    if not image then
      return
    end

    -- Couvrir toute la zone avec le fond original sans le deformer.
    -- Le tampon du widget EdgeTX coupe le debordement. Sur 480x272,
    -- le fond TX15 480x320 est centre et recadre de 24 pixels haut/bas.
    local w, h = Bitmap.getSize(image)
    local scale = math.ceil(math.max(widget.zone.w / w, widget.zone.h / h) * 100)
    local x = widget.zone.x + math.floor((widget.zone.w - w * scale / 100) / 2)
    local y = widget.zone.y + math.floor((widget.zone.h - h * scale / 100) / 2)
    if scale == 100 then
      lcd.drawBitmap(image, x, y)
    else
      lcd.drawBitmap(image, x, y, scale)
    end
  end

  local function drawLogo(t, images)
    if images.logo then
      local scale = math.floor(t.scale * 85 + 0.5)
      local x = t.x(241) - math.floor(216 * (scale / 100) / 2)
      if scale == 100 then
        lcd.drawBitmap(images.logo, x, t.y(3))
      else
        lcd.drawBitmap(images.logo, x, t.y(3), scale)
      end
    else
      centered(t, 241, 34, config.skinName or "JWAIO", BOLD, C.white)
      centered(t, 241, 53, "FPV", MIDSIZE, C.white)
    end
  end

  local function drawThrottle(t, images, percent)
    local index = throttleIndex(percent)
    if images.throttle[index] == nil then
      images.throttle[index] = openBitmap(config.basePath .. "/img/thr" .. tostring(index - 1) .. ".png") or false
    end
    centered(t, 241, 193, "THROTTLE", XSMSIZE, C.orange)
    centered(t, 241, 206, tostring(percent) .. "%", BOLD, C.white)
    local image = images.throttle[index]
    if image then
      local scale = math.floor(t.scale * 85 + 0.5)
      local x = t.x(241) - math.floor(166 * (scale / 100) / 2)
      if scale == 100 then
        lcd.drawBitmap(image, x, t.y(239))
      else
        lcd.drawBitmap(image, x, t.y(239), scale)
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
    lcd.drawRectangle(t.x(367), t.y(123), t.w(102), t.h(7), C.line, 1)
    if width > 0 then
      lcd.drawFilledRectangle(t.x(368), t.y(124), t.w(math.max(1, width - 2)), t.h(5), linkColor(state))
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
    -- Chaque capteur a sa propre validite. Seules les distances exigent le GPS.
    local gpsReady = state.gpsState == "GPS OK"
    local speedValid = state.speedValid
    local altitudeValid = state.altitudeValid
    local distanceValid = gpsReady and state.distanceValid

    local speed = speedValid and string.format("%.1f km/h", state.speed) or "NO_DATA"
    local altitude = altitudeValid and string.format("%.0f m", state.altitude) or "NO_DATA"
    local distance = distanceValid and string.format("%.3f km", state.distance / 1000) or "NO_DATA"
    local total = distanceValid and string.format("%.2f km", state.totalDistance / 1000) or "NO_DATA"

    drawMetric(t, 132, 236, 156, "Speed", speed, speedValid)
    drawMetric(t, 248, 350, 156, "Alt", altitude, altitudeValid)
    drawMetric(t, 132, 236, 173, "Dist", distance, distanceValid)
    drawMetric(t, 248, 350, 173, "Total", total, distanceValid)
  end

  local function satelliteDisplay(state)
    if not state.satsValid or not state.sats or state.sats < 0 then
      return "NO_DATA", C.grey
    end
    local count = util.round(state.sats)
    if state.satelliteLevel == 1 then return "SAT " .. tostring(count), C.red end
    if state.satelliteLevel == 2 then return "SAT " .. tostring(count), C.orange end
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
    lcd.drawRectangle(t.x(362), t.y(248), t.w(112), t.h(7), C.line, 1)
    if inside > 0 then
      lcd.drawFilledRectangle(t.x(363), t.y(249), t.w(inside), t.h(5), finderColor(strength))
    end
    lcd.drawText(t.x(362), t.y(258), "0%", XSMSIZE + C.grey)
    lcd.drawText(t.x(474), t.y(258), "100%", XSMSIZE + RIGHT_ALIGN + C.grey)
  end

  local function drawFinder(t, widget)
    panel(t, 356, 218, 124, 54, "QWAD FINDER", C.green)

    local requested = widget.data.beeper or widget.data.flip or widget.data.rth
    if not requested then
      centered(t, 418, 239, "OFF", SMLSIZE, C.grey)
      centered(t, 418, 258, "B / F / RTH", XSMSIZE, C.grey)
      return
    end

    if widget.finderLoadError then
      centered(t, 418, 241, "MODULE ERROR", XSMSIZE, C.red)
      return
    end

    local finder = widget.finder
    if not finder or not finder.valid then
      lcd.drawText(t.x(362), t.y(235), "RSSI", XSMSIZE + C.grey)
      lcd.drawText(t.x(474), t.y(235), "NO_DATA", XSMSIZE + RIGHT_ALIGN + C.grey)
      drawFinderGauge(t, finder)
      return
    end

    lcd.drawText(t.x(362), t.y(235), finder.source, XSMSIZE + C.grey)
    lcd.drawText(t.x(474), t.y(235),
      tostring(finder.value) .. " " .. finder.unit,
      XSMSIZE + RIGHT_ALIGN + C.white)
    drawFinderGauge(t, finder)
  end

  function M.draw(widget)
    local zone = widget.zone
    local t = transform(zone)
    local state = widget.data
    local flight = widget.flight

    drawBackground(t, widget)

    if zone.w < 360 or zone.h < 220 then
      centered(t, 240, 115, config.skinName or "JWAIO", BOLD, C.orange)
      centered(t, 240, 136, "UTILISER UNE ZONE PLEIN ECRAN", XSMSIZE, C.white)
      return
    end

    panel(t, 0, 0, 124, 47, "MODE DE VOL", C.orange)
    centered(t, 62, 24, state.mode, BOLD, modeColor(state.mode))

    panel(t, 0, 48, 124, 43, "FLY TIME", C.orange)
    centered(t, 62, 68, util.formatFlightTime(flight.flightSeconds), BOLD, C.white)

    panel(t, 0, 94, 124, 44, "FLY TOTAL", C.orange)
    centered(t, 62, 116, util.formatTotalTime(flight.totalSeconds), SMLSIZE, C.white)

    panel(t, 0, 175, 124, 41, "GPS", C.blue)
    local satelliteText, satelliteColor = satelliteDisplay(state)
    centered(t, 62, 192, satelliteText, BOLD, satelliteColor)

    panel(t, 0, 218, 124, 54, "DERNIERE POSITION", C.blue)
    if state.lastLat and state.lastLon then
      lcd.drawText(t.x(7), t.y(238), string.format("LAT %.5f", state.lastLat), XSMSIZE + C.white)
      lcd.drawText(t.x(7), t.y(252), string.format("LON %.5f", state.lastLon), XSMSIZE + C.white)
    else
      centered(t, 62, 243, "N/A", BOLD, C.grey)
    end

    panel(t, 356, 0, 124, 47, batteryTitle(state), C.orange)
    local batteryText = state.batteryValid and string.format("%.2fV", state.battery) or "NO_DATA"
    centered(t, 418, 24, batteryText, BOLD, batteryColor(state))

    panel(t, 356, 48, 124, 89, state.linkType or "ELRS", C.green)
    local lqText = state.lqValid and tostring(util.round(state.lq)) .. "%" or "NO_DATA"
    lcd.drawText(t.x(365), t.y(71), "LQ", XSMSIZE + C.grey)
    centered(t, 426, 68, lqText, SMLSIZE, linkColor(state))
    if state.rssiValid then
      lcd.drawText(t.x(365), t.y(97), "RSSI", XSMSIZE + C.grey)
      centered(t, 426, 94, tostring(util.round(state.rssi)) .. " dBm", XSMSIZE, C.white)
    else
      centered(t, 426, 94, "NO_DATA", XSMSIZE, C.grey)
    end
    drawLinkGauge(t, state)

    panel(t, 356, 175, 124, 41, "BEEPER / FLIP", C.orange)
    lcd.drawText(t.x(365), t.y(196), "B " .. (state.beeper and "ON" or "OFF"), SMLSIZE + (state.beeper and C.green or C.grey))
    lcd.drawText(t.x(421), t.y(196), "F " .. (state.flip and "ON" or "OFF"), SMLSIZE + (state.flip and C.red or C.grey))

    drawFinder(t, widget)

    drawLogo(t, widget.images)
    drawThrottle(t, widget.images, state.throttle)

    if widget.diagnostics and widget.diagnostics.error then
      centered(t, 241, 122, widget.diagnostics.error, XSMSIZE, C.red)
    elseif widget.logger.active then
      centered(t, 241, 122, "REC", XSMSIZE, C.red)
    elseif widget.logger.error then
      centered(t, 241, 122, widget.logger.error, XSMSIZE, C.red)
    elseif widget.images.backgroundError then
      centered(t, 241, 122, "SKIN ERROR", XSMSIZE, C.red)
    end

    -- RTH/Pre-Arm/Arm restent independants du Qwad Finder : l'etat central
    -- continue de representer uniquement la preparation et l'armement du vol.
    local status = state.armed and "Arm" or (state.prearmed and "Pre-Arm" or "Ready")
    centered(t, 241, 133, status, BOLD, state.armed and C.red or (state.prearmed and C.orange or C.green))
    drawFlightMetrics(t, state)
  end

  return M
end
