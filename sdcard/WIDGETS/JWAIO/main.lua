-- ============================================================================
-- JWAIO - Jeckyll Widget All in One
-- Copyright 2026 DrJeckyllMrHyde
-- SPDX-License-Identifier: Apache-2.0
-- Fichier : main.lua
-- Version : 0.2.1
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
local uiModule = loadModule("lib/ui.lua")(config, util)

-- EdgeTX 2.11+ limite le menu natif a dix options. Les capteurs de telemetrie
-- sont donc lus directement apres leur decouverte dans le modele.
local options = {
  { "BatType", CHOICE, 1, {"LiPo", "LiIon", "LiHv"} },
  { "Cells", VALUE, 6, 1, 8 },
  { "LinkType", CHOICE, 1, {"ELRS", "TBS_CF"} },
  { "LQ", SOURCE, util.sourceIndex("RQly") },
  { "ARM", SWITCH, util.switchIndex({"SE↓", "SE-", "SE"}) },
  { "PreArm", SWITCH, util.switchIndex({"SF↓", "SF-", "SF"}) },
  { "Beeper", SWITCH, 0 },
  { "Flip", SWITCH, 0 },
  { "RTH", SWITCH, 0 },
  { "Thr", SOURCE, util.sourceIndex("ch3") }
}

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

  -- Le module calcule la force et la cadence. Le gestionnaire audio decide
  -- ensuite si le bip peut etre joue sans couper une alerte prioritaire.
  widget.finder:update(widget.data, function()
    return audioModule.playFinderBip(widget.audio, widget.data.now)
  end)
end

local function tick(widget)
  dataModule.update(widget.data, widget.options)
  flightModule.update(widget.flight, widget.data, widget.logger)
  distanceModule.update(widget.distance, widget.data, widget.flight)
  -- Le journal passe apres le calcul afin que chaque ligne CSV contienne les
  -- distances correspondant exactement au meme echantillon GPS.
  loggerModule.update(widget.logger, widget.data)
  audioModule.update(widget.audio, widget.data)
  updateFinder(widget)
end

local function create(zone, currentOptions)
  local widget = {
    zone = zone,
    options = currentOptions,
    data = dataModule.new(),
    logger = loggerModule.new(),
    flight = flightModule.new(),
    distance = distanceModule.new(),
    audio = audioModule.new(),
    images = uiModule.loadImages(),
    finder = nil,
    finderLoadError = false
  }
  loggerModule.loadLastPosition(widget.data)
  loggerModule.loadLastDistance(widget.distance)
  return widget
end

local function update(widget, currentOptions)
  widget.options = currentOptions
end

local function refresh(widget, event, touchState)
  tick(widget)
  uiModule.draw(widget)
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
