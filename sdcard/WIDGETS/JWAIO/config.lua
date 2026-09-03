-- ============================================================================
-- JWAIO - Jeckyll Widget All in One
-- Copyright 2026 DrJeckyllMrHyde
-- SPDX-License-Identifier: Apache-2.0
-- Fichier : config.lua
-- Version : 0.2.1
-- Cible   : RadioMaster TX15 Max / EdgeTX 2.12.x
-- Role    : reglages avances, seuils, capteurs et chemins de la carte SD.
-- Conseil : modifier ce fichier radio eteinte, puis redemarrer EdgeTX.
-- ============================================================================

return {
  version = "0.2.1",
  basePath = "/WIDGETS/JWAIO",
  logPath = "/LOGS/JWAIO",
  soundPath = "/SOUNDS/fr/JWAIO",

  -- Source a trois positions : bas=ANGLE, centre=ACRO, haut=RTH.
  modeSource = "CH5",
  modeLow = -341,

  -- Capteurs directs : les decouvrir dans EdgeTX avant d'ajouter le widget.
  batterySource = "RxBt",
  gpsSource = "GPS",
  altitudeSource = "Alt",
  speedSource = "GSpd",
  speedMultiplier = 1.0, -- GSpd est deja fourni en km/h sur le modele teste
  satellitesSource = "Sats",
  rssiSource = "1RSS",

  -- Batterie, valeurs par cellule. Le profil actif est choisi dans le menu.
  batteryProfiles = {
    [1] = {
      name="LiPo", warn=3.60, critical=3.40, recover=3.68,
      full=4.10, fullSound="batteryFullStandard"
    },
    [2] = {
      name="LiIon", warn=3.00, critical=2.80, recover=3.08,
      full=4.10, fullSound="batteryFullStandard"
    },
    [3] = {
      name="LiHv", warn=3.60, critical=3.40, recover=3.68,
      full=4.20, maximum=4.35, fullSound="batteryFullLihv"
    }
  },
  batteryHoldSeconds = 1.2,
  batteryCriticalHoldSeconds = 1.0,
  batteryRepeatSeconds = 2.0,
  batteryReconnectSeconds = 3.0,
  perCellAutoMax = 5.20,

  -- Compteurs EdgeTX : index 0 = TIMER 1, index 1 = TIMER 2.
  flyTimeTimer = 0,
  flyTotalTimer = 1,

  -- ELRS.
  lqWarn = 70,
  lqCritical = 50,
  lqRecover = 75,
  linkHoldSeconds = 2.0,

  -- Qwad Finder. La formule reprend le principe du script MIT de Sunil Chahal:
  -- lissage exponentiel puis conversion de -110...-40 dBm vers 0...100 %.
  -- Le bip WAV durant environ 0,56 s, la cadence minimale reste a 0,65 s pour
  -- eviter le chevauchement des lectures a proximite du quad.
  finderRssiMinimum = -110,
  finderRssiMaximum = -40,
  finderFilterAlpha = 0.20,
  finderFarSeconds = 2.00,
  finderNearSeconds = 0.65,
  finderAudioReserveSeconds = 0.60,

  -- Protection ESC.
  throttleAlertPercent = 95,
  throttleAlertSeconds = 3.0,
  throttleResetPercent = 90,

  -- GPS.
  gpsReadySatellites = 5,
  gpsLostHoldSeconds = 2.0,
  navigationPeriodSeconds = 1.0,
  altitudeAlertMeters = 120,

  -- Distances GPS. Un vrai vol ne commence qu'une fois ARM actif et le
  -- throttle strictement superieur a 5 %. Un controle moteur a 5 % ou moins
  -- ne remet donc jamais les resultats du dernier vol a zero.
  distanceStartThrottlePercent = 5,
  distanceEarthRadiusMeters = 6371000,
  distanceMinimumSpeedKmh = 1.0,
  distanceMinimumSegmentMeters = 1.0,
  distanceMaximumSpeedKmh = 400,
  distanceMaximumSampleGapSeconds = 2.5,
  distanceJumpMarginMeters = 30,
  distanceSavePeriodSeconds = 1.0,

  -- Ecriture carte SD.
  logPeriodSeconds = 1.0,

  -- EdgeTX documente officiellement le WAV PCM. Mettre ".mp3" seulement
  -- pour un essai explicite sur la radio avec les fichiers correspondants.
  audioExtension = ".wav",
  audioGapSeconds = 3.2,
  sounds = {
    acro = "Acro",
    altitude = "Altitude",
    angle = "angle",
    arm = "arm",
    batteryLow = "batlow",
    batteryCritical = "batcrt",
    batteryFullLihv = "Lihv_Full",
    batteryFullStandard = "Lipo_Liion_Full",
    beeper = "beeper",
    flip = "flip",
    link = "elrs",
    gps = "gps",
    preArm = "pre_arm",
    rth = "RTH",
    satellite = "Satellite",
    throttle = "thr",
    finderBip = "finder_bip"
  },

  -- Affiche des donnees simulees pour valider le layout, sans drone.
  -- Toujours remettre false avant le vol.
  demo = false
}
