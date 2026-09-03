-- ============================================================================
-- JWAIO - Jeckyll Widget All in One
-- Copyright 2026 DrJeckyllMrHyde
-- SPDX-License-Identifier: Apache-2.0
-- Fichier : lib/util.lua
-- Version : 0.2.1
-- Role    : petites fonctions communes sans etat propre.
-- ============================================================================

local M = {}

-- Borne une valeur numerique. Utilisee par l'affichage, la batterie et le
-- Qwad Finder pour ne jamais depasser les plages attendues.
function M.clamp(value, minimum, maximum)
  if value < minimum then return minimum end
  if value > maximum then return maximum end
  return value
end

function M.round(value)
  if value >= 0 then return math.floor(value + 0.5) end
  return math.ceil(value - 0.5)
end

function M.option(options, name, fallback)
  if options and options[name] ~= nil then return options[name] end
  return fallback
end

-- Convertit une source EdgeTX nommee en identifiant une seule fois au
-- chargement. Cela evite une recherche par nom a chaque rafraichissement.
function M.sourceIndex(name)
  if type(name) ~= "string" or name == "" then return 0 end
  if getFieldInfo then
    local ok, field = pcall(getFieldInfo, name)
    if ok and field and field.id and field.id ~= 0 then return field.id end
  end
  if getSourceIndex then
    local ok, index = pcall(getSourceIndex, name)
    if ok and index and index ~= 0 then return index end
  end
  return 0
end

-- Les noms de position de switch peuvent varier legerement suivant le theme ou
-- la version EdgeTX. Le premier alias reconnu devient la valeur par defaut.
function M.switchIndex(names)
  if not getSwitchIndex then return 0 end
  for _, name in ipairs(names or {}) do
    local ok, index = pcall(getSwitchIndex, name)
    if ok and index and index ~= 0 then return index end
  end
  return 0
end

-- Fly Time reste volontairement sur MM:SS alors que Fly Total peut depasser
-- une heure et utilise HH:MM:SS.
function M.formatFlightTime(seconds)
  local value = math.max(0, math.floor(seconds or 0))
  local minutes = math.floor(value / 60)
  local secs = value % 60
  return string.format("%02d:%02d", minutes, secs)
end

function M.formatTotalTime(seconds)
  local value = math.max(0, math.floor(seconds or 0))
  local hours = math.floor(value / 3600)
  local minutes = math.floor((value % 3600) / 60)
  local secs = value % 60
  return string.format("%02d:%02d:%02d", hours, minutes, secs)
end

-- getDateTime est protege afin qu'un probleme d'horloge ne fasse jamais tomber
-- le widget ni l'enregistrement GPS.
function M.safeDateTime()
  local ok, value = pcall(getDateTime)
  if ok and type(value) == "table" then return value end
  return { year=2000, mon=1, day=1, hour=0, min=0, sec=0 }
end

function M.fileStamp()
  local dt = M.safeDateTime()
  return string.format("%02d%02d%02d_%02d%02d%02d",
    (dt.year or 2000) % 100, dt.mon or 1, dt.day or 1,
    dt.hour or 0, dt.min or 0, dt.sec or 0)
end

function M.dateText()
  local dt = M.safeDateTime()
  return string.format("%04d-%02d-%02d", dt.year or 2000, dt.mon or 1, dt.day or 1)
end

function M.timeText()
  local dt = M.safeDateTime()
  return string.format("%02d:%02d:%02d", dt.hour or 0, dt.min or 0, dt.sec or 0)
end

return M
