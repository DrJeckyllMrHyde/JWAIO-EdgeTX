local enabled = 0 -- 0 : desactive ; 1 : active. Redemarrer apres modification.
-- JWAIO v0.3.1_Alpha | Apache-2.0 | Copyright 2026 DrJeckyllMrHyde
-- TX15 : les 20 premiers indices sont vises (anneaux a confirmer sur radio).
-- Desactiver les autres scripts RGBLED EdgeTX avant de choisir 1.
return {
  enabled=enabled,
  count=20,
  brightness=20, -- pourcentage, 0 a 100 ; pas une mesure de consommation
  fps=10,        -- rafraichissement maximal ; autorise 1 a 20
  colors={ready={30,110,255},armed={0,220,80},prearm={255,130,0},
    critical={255,0,0},finder={40,160,255},lost={255,70,0},satellite={0,255,80}}
}
