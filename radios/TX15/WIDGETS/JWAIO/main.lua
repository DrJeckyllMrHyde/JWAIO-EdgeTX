-- ============================================================================
-- JWAIO - Jeckyll Widget All in One
-- Copyright 2026 DrJeckyllMrHyde
-- SPDX-License-Identifier: Apache-2.0
-- Fichier : main.lua
-- Version : 0.3.1 Alpha
-- Cible   : RadioMaster TX15 Max / EdgeTX 2.12.x
-- Role    : point d'entree du widget, menu et orchestration des modules.
-- ============================================================================

local BASE = "/WIDGETS/JWAIO/"

local function loadModule(path)
  local chunk, errorMessage = loadScript(BASE .. path, "tx")
  if not chunk then error(errorMessage or ("Module absent: " .. path)) end
  return chunk()
end

local config = loadModule("config.lua")
local util = loadModule("lib/util.lua")
local dataModule = loadModule("lib/data.lua")(config, util)
local loggerModule = loadModule("lib/logger.lua")(config, util)
local flightModule = loadModule("lib/flight.lua")(config, loggerModule)
local distanceModule = loadModule("lib/distance.lua")(config, util, loggerModule)
local audioModule = loadModule("lib/audio.lua")(config)
local mediaModule = loadModule("lib/media.lua")(config)
local ledModule = loadModule("lib/leds.lua")()
local diagnosticsModule = loadModule("lib/diagnostics.lua")(config, util, loggerModule)
local skinModule = loadModule("lib/skin.lua")(config)
local skinCatalog = skinModule.discover()
local uiFactory = loadModule("lib/ui.lua")

-- EdgeTX 2.11+ limite le menu natif a dix options. Les capteurs de telemetrie
-- sont donc lus directement apres leur decouverte dans le modele.
local options = {
  { "Skin", CHOICE, skinCatalog.defaultIndex, skinCatalog.choices },
  { "BatType", CHOICE, 1, {"LiPo", "LiIon", "LiHv"} },
  { "Cells", VALUE, 6, 1, 8 },
  { "LinkType", CHOICE, 1, {"ELRS", "TBS_CF"} },
  { "ARM", SWITCH, util.switchIndex({"SE↓", "SE-", "SE"}) },
  { "PreArm", SWITCH, util.switchIndex({"SF↓", "SF-", "SF"}) },
  { "Beeper", SWITCH, 0 },
  { "Flip", SWITCH, 0 },
  { "RTH", SWITCH, 0 },
  { "Thr", SOURCE, util.sourceIndex("ch3") }
}

-- Le changement de skin libere d'abord les anciens bitmaps, puis ne charge
-- que le fond et le logo selectionnes. Les jauges throttle restent partagees.
local function applySkin(widget, requestedIndex)
  local skin, resolvedIndex = skinModule.resolve(skinCatalog, requestedIndex)
  if widget.skin and widget.skin.id == skin.id and widget.ui and widget.images then
    widget.skinIndex = resolvedIndex
    return
  end

  widget.images = nil
  widget.ui = nil
  ledModule.stop(widget.leds)
  if collectgarbage then pcall(collectgarbage, "collect") end

  widget.ui = uiFactory(skinModule.uiConfig(skin), util)
  widget.images = widget.ui.loadImages()
  widget.skin = skin
  widget.skinIndex = resolvedIndex
  -- Conserver episodes et file d'alertes : changer de skin ne rejoue pas ARM
  -- ou batterie pleine. Seuls les chemins et les durees sont remplaces.
  if not widget.audio.assets then widget.audio.assets = mediaModule.load() end
  widget.leds = ledModule.load(skin)
end

-- Le Qwad Finder est volontairement absent de la liste des modules charges
-- ci-dessus. Il ne doit occuper de la RAM que pendant une recherche effective.
local function finderRequested(state)
  return state.beeper or state.flip or state.rth
end

local function loadFinder(widget)
  if widget.finder or widget.finderLoadError then return end

  local ok, instance = pcall(function()
    return loadModule("lib/finder.lua")(config, util)
  end)

  if ok and instance then
    widget.finder = instance
  else
    -- Memoriser l'erreur evite de retenter un chargement a chaque trame.
    -- Un nouveau passage des trois commandes sur OFF rearmera un essai.
    widget.finderLoadError = true
  end
end

local function releaseFinder(widget)
  if not widget.finder and not widget.finderLoadError then return end
  widget.finder = nil
  widget.finderLoadError = false

  -- La collecte n'est demandee qu'au changement d'etat, jamais en boucle.
  if collectgarbage then pcall(collectgarbage, "collect") end
end

local function updateFinder(widget)
  if not finderRequested(widget.data) then
    releaseFinder(widget)
    return
  end

  loadFinder(widget)
  if not widget.finder then return end

  -- Le module calcule la force et la cadence. L'audio lui donne la priorite
  -- sur les annonces JWAIO des que Beeper, Flip ou RTH active la recherche.
  widget.finder:update(widget.data, function()
    return audioModule.playFinderBip(widget.audio, widget.data.now)
  end)
end

local function tick(widget)
  -- EdgeTX peut appeler refresh et background au meme instant : une seule
  -- acquisition par tick de 10 ms, sans doubler les compteurs de diagnostic.
  local tickTime = getTime()
  if widget.lastTick == tickTime then return end
  widget.lastTick = tickTime
  dataModule.update(widget.data, widget.options)
  flightModule.update(widget.flight, widget.data, widget.logger)
  diagnosticsModule.beginTick(widget.diagnostics, widget.data, widget.logger.filename)
  audioModule.update(widget.audio, widget.data)
  updateFinder(widget)
  ledModule.update(widget.leds, widget.data, widget.finder, widget.audio)
  distanceModule.update(widget.distance, widget.data, widget.flight)
  -- Le journal passe apres le calcul afin que chaque ligne CSV contienne les
  -- distances correspondant exactement au meme echantillon GPS.
  loggerModule.update(widget.logger, widget.data, widget.finder)
  diagnosticsModule.endTick(widget.diagnostics, widget.data, widget.finder)
end

local function create(zone, currentOptions)
  local widget = {
    zone = zone,
    options = currentOptions,
    data = dataModule.new(),
    logger = loggerModule.new(),
    flight = flightModule.new(),
    distance = distanceModule.new(),
    diagnostics = diagnosticsModule.new(),
    finder = nil,
    finderLoadError = false
  }
  widget.audio = audioModule.new(function(event, subject, detail)
    if subject == "finderBip" and widget.finder and widget.finder.valid then
      local finder = widget.finder
      detail = string.format("%s=%d strength=%.1f period=%.2f",
        finder.source, finder.value, finder.strength, finder.period or 0)
    end
    diagnosticsModule.event(widget.diagnostics, widget.data.now, event, subject, detail)
  end)
  applySkin(widget, util.option(currentOptions, "Skin", skinCatalog.defaultIndex))
  loggerModule.loadLastPosition(widget.data)
  loggerModule.loadLastDistance(widget.distance)
  return widget
end

local function update(widget, currentOptions)
  widget.options = currentOptions
  applySkin(widget, util.option(currentOptions, "Skin", skinCatalog.defaultIndex))
end

local function refresh(widget, event, touchState)
  tick(widget)
  widget.ui.draw(widget)
end

local function background(widget)
  tick(widget)
end

return {
  name = "JWAIO",
  options = options,
  create = create,
  update = update,
  refresh = refresh,
  background = background
}
