-- ============================================================================
-- JWAIO - Jeckyll Widget All in One
-- Copyright 2026 DrJeckyllMrHyde
-- SPDX-License-Identifier: Apache-2.0
-- Fichier : skins/jwaio/skin.lua
-- Version : 0.3.1_Alpha
-- Role    : identite, fichiers et palette du skin officiel JWAIO.
-- Note    : les numeros de slot ne doivent jamais changer apres publication.
-- Medias  : sons communs SOUNDS/fr/JWAIO ; effets dans leds/.
-- ============================================================================

return {
  api = 1,
  id = "jwaio",
  name = "JWAIO",
  slot = 1,
  background = "background.png",
  logo = "logo.png",
  -- Le fond reste une image continue. Les aplats des modules sont dessines
  -- par lib/ui.lua afin de ne plus decouper visuellement le paysage.
  panelsBaked = false,
  palette = {
    black = {0, 0, 0},
    panel = {9, 11, 14},
    line = {45, 116, 210},
    white = {244, 246, 248},
    grey = {135, 143, 153},
    orange = {255, 132, 28},
    green = {126, 190, 38},
    red = {255, 55, 55},
    blue = {75, 142, 255}
  }
}
