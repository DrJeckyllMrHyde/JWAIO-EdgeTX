-- ============================================================================
-- JWAIO - Jeckyll Widget All in One
-- Copyright 2026 DrJeckyllMrHyde
-- SPDX-License-Identifier: Apache-2.0
-- Fichier : lib/skin.lua
-- Version : 0.3.0
-- Role    : decouverte, validation et selection des skins installes.
-- ============================================================================

return function(config)
  local M = {}
  local root = config.basePath .. "/skins"
  local expectedApi = config.skinApi or 1
  local maximumSlots = config.maximumSkinSlots or 8

  local function safeName(value)
    return type(value) == "string" and value ~= "." and value ~= ".." and
      #value <= 32 and string.match(value, "^[%w_.-]+$") ~= nil
  end

  local function integer(value)
    return type(value) == "number" and value == math.floor(value)
  end

  local function loadManifest(folder)
    if not safeName(folder) then return nil end

    local path = root .. "/" .. folder
    local okLoad, chunk = pcall(loadScript, path .. "/skin.lua", "tx")
    if not okLoad or type(chunk) ~= "function" then return nil end

    local okRun, skin = pcall(chunk)
    if not okRun or type(skin) ~= "table" then return nil end
    if skin.api ~= expectedApi then return nil end
    if not safeName(skin.id) or type(skin.name) ~= "string" then return nil end
    if #skin.name < 1 or #skin.name > 10 then return nil end
    if not integer(skin.slot) or skin.slot < 1 or skin.slot > maximumSlots then return nil end
    if not safeName(skin.logo) or not safeName(skin.background) then return nil end
    if type(skin.palette) ~= "table" then return nil end
    for _, rgb in pairs(skin.palette) do
      if type(rgb) ~= "table" or #rgb ~= 3 then return nil end
      for _, component in ipairs(rgb) do
        if not integer(component) or component < 0 or component > 255 then return nil end
      end
    end

    skin.folder = folder
    skin.path = path
    return skin
  end

  local function add(catalog, seenFolders, folder)
    if seenFolders[folder] then return end
    seenFolders[folder] = true

    local skin = loadManifest(folder)
    if not skin or catalog.skins[skin.slot] then return end
    catalog.skins[skin.slot] = skin
    if skin.slot > catalog.maximumSlot then catalog.maximumSlot = skin.slot end
  end

  function M.discover()
    local catalog = {
      skins = {},
      choices = {},
      maximumSlot = 0,
      defaultIndex = 1
    }
    local seenFolders = {}

    -- Le skin original est tente en premier afin d'assurer le secours meme si
    -- l'enumeration de repertoire n'est pas disponible ou echoue.
    add(catalog, seenFolders, config.defaultSkinFolder or "jwaio")

    if dir then
      local okDir, iterator = pcall(dir, root)
      if okDir and type(iterator) == "function" then
        while true do
          local okNext, folder = pcall(iterator)
          if not okNext or folder == nil then break end
          if type(folder) == "string" then add(catalog, seenFolders, folder) end
        end
      end
    end

    -- Dernier filet de securite pour une installation partielle. L'interface
    -- reste exploitable en noir et utilise l'ancien logo partage si present.
    if not catalog.skins[1] then
      catalog.skins[1] = {
        api = expectedApi,
        id = "fallback",
        name = "JWAIO",
        slot = 1,
        path = config.basePath .. "/img",
        logo = "logo.png",
        background = "background.png",
        panelsBaked = false,
        palette = {}
      }
      catalog.maximumSlot = math.max(1, catalog.maximumSlot)
    end

    for slot = 1, math.max(1, catalog.maximumSlot) do
      local skin = catalog.skins[slot]
      catalog.choices[slot] = skin and skin.name or "N/A"
    end
    return catalog
  end

  function M.resolve(catalog, requestedIndex)
    local index = tonumber(requestedIndex) or catalog.defaultIndex
    index = math.floor(index)
    local skin = catalog.skins[index]
    if not skin then
      index = catalog.defaultIndex
      skin = catalog.skins[index]
    end
    return skin, index
  end

  -- L'UI recoit une copie superficielle de la configuration principale. Les
  -- autres modules ne voient donc jamais les couleurs ou chemins du skin.
  function M.uiConfig(skin)
    local themed = {}
    for key, value in pairs(config) do themed[key] = value end
    themed.skinPath = skin.path
    themed.logoImage = skin.logo
    themed.backgroundImage = skin.background
    themed.backgroundIncludesPanels = skin.panelsBaked == true
    themed.palette = skin.palette
    themed.skinName = skin.name
    return themed
  end

  return M
end
