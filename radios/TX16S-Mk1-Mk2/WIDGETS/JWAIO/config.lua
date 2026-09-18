-- ============================================================================
-- JWAIO - Jeckyll Widget All in One
-- Copyright 2026 DrJeckyllMrHyde
-- SPDX-License-Identifier: Apache-2.0
-- Fichier : config.lua
-- Version : 0.3.1 Alpha - port TX16S Mk1/Mk2
-- Cible   : RadioMaster TX16S Mk1 / Mk2 - EdgeTX 2.12.x
-- Role    : reglages avances, seuils, capteurs et chemins du stockage EdgeTX.
-- Conseil : modifier ce fichier radio eteinte, puis redemarrer EdgeTX.
-- ============================================================================

return {
  version = "0.3.1",
  iteration = "Alpha-TX16S-Mk1-Mk2",
  basePath = "/WIDGETS/JWAIO",
  logPath = "/LOGS/JWAIO",
  soundPath = "/SOUNDS/fr/JWAIO",

  -- Les skins disposent de slots stables : EdgeTX memorise l'index CHOICE.
  -- Le dossier original reste toujours le filet de securite du widget.
  skinApi = 1,
  defaultSkinFolder = "jwaio",
  maximumSkinSlots = 8,

  -- Commande d'affichage uniquement : ne modifie jamais les modes du drone.
  -- Source physique SA ; position ANGLE : -1 / 0 / 1 (valeur source).
  -- Le switch RTH du menu reste prioritaire, independamment de SA.
  modeSource = "sa",
  modeAnglePosition = 1, -- SA bas ; haut=-1, milieu=0
  modeLow = -341,
  modeHigh = 341,

  -- Capteurs directs : les decouvrir dans EdgeTX avant d'ajouter le widget.
  batterySource = "RxBt",
  gpsSource = "GPS",
  altitudeSource = "Alt",
  speedSource = "GSpd",
  speedMultiplier = 1.0, -- GSpd est deja fourni en km/h sur le modele teste
  satellitesSource = "Sats",
  lqSource = "RQly",
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
  -- Une annonce par episode : rearmement seulement apres recuperation stable.
  batteryRecoverySeconds = 5.0,
  batteryCriticalRecoveryMargin = 0.08,
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
  -- Nouveau bip WAV de 0,143 s. La cadence minimale de 0,20 s laisse une pause.
  -- Lissage en temps reel, independant de la cadence des appels EdgeTX.
  finderRssiMinimum = -110,
  finderRssiMaximum = -40,
  finderFilterSeconds = 0.10,
  finderFarSeconds = 1.20,
  finderNearSeconds = 0.20,
  finderAudioReserveSeconds = 0.20,

  -- Protection ESC.
  throttleAlertPercent = 95,
  throttleAlertSeconds = 3.0,
  throttleResetPercent = 90,

  -- GPS.
  gpsReadySatellites = 5,
  -- Plages inclusives : 0-4 rouge, 5-6 orange, 7+ vert.
  -- Modifiable ici sans consommer une onzieme option du menu.
  gpsRescueSatellites = 7,
  satelliteHoldSeconds = 2.0,
  -- Pack satellite fourni et mesure le 09/09/2026.
  satelliteExtraSoundsReady = true,
  gpsLostHoldSeconds = 2.0,
  navigationPeriodSeconds = 1.0,
  altitudeAlertMeters = 120,
  altitudeReference = "sensor", -- Alt affiche > 120 m ; option avancee "relative"

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

  -- Ecriture stockage EdgeTX. Diagnostics prives pour les essais terrain :
  -- aucun menu supplementaire, tampon borne, ecriture groupee a 1 Hz.
  logPeriodSeconds = 1.0,
  diagnosticsEnabled = true,
  diagnosticBufferLimit = 64,
  diagnosticFlushSeconds = 1.0,

  -- EdgeTX documente officiellement le WAV PCM. Mettre ".mp3" seulement
  -- pour un essai explicite sur la radio avec les fichiers correspondants.
  audioExtension = ".wav",
  audioGapSeconds = 3.2,
  -- Durees arrondies par exces du nouveau pack WAV PCM mono 32 kHz.
  -- Elles evitent la file audio EdgeTX et remplacent l'attente fixe de 3,2 s.
  audioPaddingSeconds = 0.08,
  soundDurations = {
    acro=0.68, altitude=1.33, angle=0.68, arm=0.83,
    batteryCritical=1.92, batteryLow=1.27, beeper=1.01, link=1.74,
    finderBip=0.15, flip=0.85, gps=0.49, batteryFullLihv=0.87,
    batteryFullStandard=0.85, preArm=0.63, rth=0.74, satellite=1.06,
    throttle=0.34,
    satelliteNoRescue=1.35, satelliteRescue=1.46, satelliteLimitRescue=1.50
  },
  sounds = {
    acro = "Acro",
    altitude = "Alt",
    angle = "angle",
    arm = "arm",
    batteryLow = "batlow",
    batteryCritical = "batcrt",
    batteryFullLihv = "Lihv_Full",
    batteryFullStandard = "LipLii_full",
    beeper = "beeper",
    flip = "flip",
    link = "elrs",
    gps = "gps",
    preArm = "pre_arm",
    rth = "RTH",
    satellite = "stl",
    satelliteRescue = "stl_rs",
    satelliteNoRescue = "stl_nors",
    satelliteLimitRescue = "stl_Limrs",
    throttle = "thr",
    finderBip = "finder_bip"
  },

  -- Affiche des donnees simulees pour valider le layout, sans drone.
  -- Toujours remettre false avant le vol.
  demo = false
}
