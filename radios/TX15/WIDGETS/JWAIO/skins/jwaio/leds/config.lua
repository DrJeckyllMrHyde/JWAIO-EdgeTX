local enabled = 1 -- 0 : desactive ; 1 : active. Redemarrer apres modification.
-- JWAIO v0.3.1_Alpha | Apache-2.0 | Copyright 2026 DrJeckyllMrHyde
-- TX15 : les 20 premiers indices sont vises (anneaux a confirmer sur radio).
-- Desactiver les autres scripts RGBLED EdgeTX avant de choisir 1.
return {
  enabled=enabled,
  count=20,
  brightness=30, -- pourcentage, 0 a 100 ; pas une mesure de consommation
  fps=10,        -- rafraichissement maximal ; autorise 1 a 20
  colors={
    ready={242,244,255},     -- blanc chaud, tres leger reflet bleu
    prearm={255,158,35},     -- or Jeckyll
    armed={30,125,255},      -- bleu reactif aux manches
    angle={0,255,80},        -- vert reactif aux manches en ANGLE
    critical={255,0,0},
    finder={0,255,80},
    lost={255,70,0},
    satellite={0,255,80}
  }
}
