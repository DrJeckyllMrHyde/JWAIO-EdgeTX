-- ============================================================================
-- JWAIO - REGLAGES LED FACILES
--
-- Pour personnaliser le skin, modifie UNIQUEMENT les valeurs de ce fichier.
-- Les couleurs sont au format RGB {rouge, vert, bleu}, chaque nombre allant de
-- 0 a 255. Exemple violet : {180, 40, 255}. Redemarre EdgeTX apres sauvegarde.
-- ============================================================================
local enabled = 1 -- 1 = LEDs actives ; 0 = LEDs eteintes.

return {
  -- TX15 : 20 LEDs (deux anneaux de 10). Ne modifier que pour une autre radio.
  enabled=enabled,
  count=20,
  brightness=30, -- Luminosite generale : 0 a 100 %. Commencer vers 20-30 %.
  fps=10,        -- Fluidite : 1 a 20. Ne pas augmenter sans raison.

  -- COULEURS DU SKIN : modifier ces lignes pour creer une nouvelle ambiance.
  colors={
    ready={242,244,255},     -- Radio prete : respiration lente.
    prearm={255,158,35},     -- Pre-arm : pulsation calme.
    armed={30,125,255},      -- ACRO : halo qui suit les manches.
    angle={0,255,80},        -- ANGLE : halo qui suit les manches.
    critical={255,0,0},      -- Batterie basse/critique et RTH : rouge reserve.
    finder={0,255,80},       -- Finder et GPS acquis.
    lost={255,70,0},         -- Finder sans signal exploitable.
    satellite={0,255,80}     -- Les trois flashs de GPS acquis.
  }
}
