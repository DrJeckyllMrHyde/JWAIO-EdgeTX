# Changelog

## 0.2.1 - Distances GPS et présentation en deux colonnes

- Présentation PDF ramenée à six pages synthétiques avec le logo du projet et
  une photographie de l'interface finale sur TX15 Max.
- Ajout de la photographie finale au README et du lien direct vers le site
  gratuit et open source Open Drone Log dans la documentation rapide.
- Ajout de la distance horizontale actuelle entre le drone et le point Home.
- Ajout de la distance maximale au Home et du trajet total intégré depuis
  `GSpd`, avec repli sur les segments GPS.
- Nouveau vol de distance déclenché uniquement avec ARM actif et throttle
  strictement supérieur à 5 %. Les contrôles moteur à faible throttle ne
  réinitialisent rien.
- Sauvegarde à 1 Hz, au désarmement et avant le vol réel suivant dans
  `/LOGS/JWAIO/lastdistance.txt`.
- Filtrage de la vitesse GPS résiduelle au sol et des sauts de coordonnées
  physiquement impossibles.
- Ajout de `distance_home_m`, `distance_total_m` et `distance_max_m` au CSV.
- Zone centrale réorganisée sans cadre : Speed/Dist à gauche, Alt/Total à droite.
- Affichage `NO_DATA` pour ces quatre valeurs lorsque le GPS n'est pas prêt.
- Correction de l'alignement de `NO_DATA` avec la constante native `RIGHT`
  d'EdgeTX afin d'éviter les débordements des deux colonnes.
- Ajout du mode d'emploi TXT, de la présentation PDF et des licences destinées
  à la publication du dépôt.
- Ajout d'un convertisseur des journaux JWAIO vers le format CSV cible d'Open
  Drone Log, sans modifier le fichier enregistré par la radio.

## 0.2.0 - JWAIO et Qwad Finder

- Nouveau nom du widget : JWAIO, pour Jeckyll Widget All in One.
- Renommage des dossiers actifs en `/WIDGETS/JWAIO`, `/SOUNDS/fr/JWAIO` et
  `/LOGS/JWAIO`.
- Intégration de Qwad Finder dans le bloc inférieur droit avec RSSI/LQ, valeur
  lissée et jauge 0 à 100 %.
- Cadence de `finder_bip.wav` raccourcie progressivement lorsque le signal reçu
  augmente.
- Chargement du module uniquement si Beeper, Flip ou RTH est actif, puis
  libération et collecte mémoire lorsque les trois commandes sont inactives.
- Priorité conservée pour les alertes vocales de sécurité : le bip de recherche
  attend que leur lecture soit terminée.
- Ajout de cartouches et de commentaires de maintenance dans tous les Lua.
- Analyse complète du finder MIT de Sunil Chahal ; `fieldnotes.lua`, sans rapport
  avec la recherche RSSI, n'est pas intégré.

## 0.1.6 - LiHv et annonces vocales

- Ajout de LiHv au menu `BatType` avec tension nominale pleine jusqu'à 4,35 V
  par cellule et annonce `Lihv_Full.wav` au branchement au-dessus de 4,20 V.
- Annonce `Lipo_Liion_Full.wav` au branchement d'une LiPo ou LiIon au-dessus de
  4,10 V par cellule.
- Seuils LiIon ajustés à 3,00 V pour l'avertissement et 2,80 V pour le critique.
- Seuils LiPo et LiHv conservés à 3,60 V et 3,40 V par cellule, avec temporisation
  contre les chutes de tension brèves.
- Ajout des annonces ACRO, ANGLE, ARM, PRE-ARM, RTH, Beeper et Flip sur front
  d'activation.
- Ajout de l'annonce satellite lors de l'acquisition d'un fix GPS valide.
- Ajout de l'annonce altitude une seule fois par vol, au-delà de 120 m gagnés
  depuis l'altitude mesurée à l'armement.
- Alerte throttle réglée à trois secondes à 95 % ou plus.
- Remplacement de l'annonce audio unique en attente par une file priorisée et
  dédupliquée afin de conserver les événements simultanés sans chevauchement.
- Intégration et validation des 17 fichiers WAV fournis, tous en mono 16 bits
  32 kHz. `finder_bip.wav` est conservé pour l'étape ELRS Finder.

## 0.1.5 - Nettoyage et stabilisation avant ELRS Finder

- Centralisation de la résolution des sources et switches dans `lib/util.lua`.
- Résolution unique au chargement des identifiants `RxBt`, `GPS`, `Alt`, `GSpd`,
  `Sats`, `1RSS` et `Dist` afin d'éviter les recherches par nom répétées.
- Suppression des anciennes fonctions de compteur sur fichier, devenues inutiles
  depuis l'utilisation de TIMER 1 et TIMER 2.
- Simplification du module de vol et des appels de couleur de l'interface.
- Protection des journaux contre l'écrasement lors de deux armements dans la même
  seconde, avec suffixes `_01` à `_99`.
- Extension du banc de test : menu de dix options, démarrage sans télémétrie,
  timers, profils LiPo/LiIon, GPS à 1 Hz, couleurs satellites, RTH, audio,
  journal CSV, dernière position et collision de noms de fichiers.
- Documentation et procédure de test mises à jour avant l'intégration du mini
  ELRS Finder.

## 0.1.4 - Corrections du premier essai GPS

- Nombre de satellites affiché comme valeur principale du bloc GPS.
- `SAT 0` ou capteur absent : `NO_DATA` gris.
- `SAT 1` à `SAT 4` en rouge, `SAT 5` à `SAT 7` en orange, puis vert à partir de 8.
- Lecture GPS, altitude, vitesse et satellites synchronisée à 1 Hz avec le journal.
- Coordonnées GPS courantes affichées dans le bloc dernière position puis conservées en cas de perte.
- Dernière position enregistrée sur la carte SD à chaque ligne CSV, pas seulement au désarmement.
- Résolution directe de `GPS`, `Alt`, `GSpd` et `Sats` par leurs noms internes EdgeTX.
- Remplacement de `VSpd` par le capteur réellement découvert `GSpd`, déjà exprimé en km/h.

## 0.1.3 - Préparation des essais GPS

- Menu natif réorganisé avec exactement dix réglages : BatType, Cells, LinkType,
  LQ, ARM, PreArm, Beeper, Flip, RTH et Thr.
- Nombre de cellules réglé à 6S par défaut, avec choix de 1S à 8S.
- Lecture directe des capteurs découverts `RxBt`, `GPS`, `Alt`, `VSpd` et `Sats`.
- Ajout du switch RTH, prioritaire sur ANGLE/ACRO.
- Ajout de la ligne centrale `Speed` en km/h et `Alt` en mètres, avec conversion
  de `VSpd` de m/s vers km/h.
- Remontée légère des états Ready, Pre-Arm et Arm.
- Remise à zéro de TIMER 1 au démarrage désarmé et à chaque désarmement.
- TIMER 2 reste inchangé pour conserver Fly Total.
- État `NO_DATA` confirmé au démarrage sans télémétrie.

## 0.1.2 - Timers radio, batteries et protocole de liaison

- Fly Time relié au TIMER 1 natif de la radio.
- Fly Total relié au TIMER 2 natif de la radio, sans compteur parallèle du widget.
- Choix LiPo/LiIon dans le menu, avec seuils LiIon à 3,10 V et 2,90 V par cellule.
- Libellé automatique `CELL LIPO` ou `CELL LIION`.
- Choix `ELRS` ou `TBS_CF` dans le menu du widget.
- Réorganisation du bloc liaison pour séparer LQ, RSSI et jauge.
- Remplacement de l'état `SOL` par `Ready` en vert ; conservation de `Pre-Arm` et `Arm`.
- Suppression de l'affichage et du réglage général `SON` ; les alertes de sécurité restent actives.

## 0.1.1 - Retour du premier essai TX15 Max

- Réduction générale des polices pour éviter les chevauchements sur l'écran réel.
- Titres passés à la police XXS EdgeTX ; valeurs principales ramenées à BOLD/SML.
- Correction de l'erreur à l'armement dans `logger.lua`.
- Remplacement des appels `handle:write/read/close` par l'API simplifiée EdgeTX
  `io.write/read/close`.
- Fermeture du fichier après chaque ligne CSV pour finaliser l'écriture sur la SD.
- Lecture compatible EdgeTX des fichiers Fly Total et dernière position.

## 0.1.0 - Première itération

- Structure de carte SD installable.
- Widget plein écran 480 x 320 avec adaptation à la zone EdgeTX.
- Dix options natives pour les sources et switches essentiels.
- Lecture throttle, batterie, LQ, GPS, satellites, ARM, PRE-ARM, Beeper et Flip.
- Modes ANGLE / ACRO / RTH à partir d'une source configurable dans `config.lua`.
- Fly Time et Fly Total internes au premier prototype.
- Journal CSV à 1 Hz, un fichier par armement.
- Dernière position GPS valide protégée contre les valeurs nulles.
- Gestionnaire audio priorisé avec temporisations, répétitions et réarmement.
- Sons WAV de test et ressources PNG allégées.
- Emplacement réservé au mini ELRS Finder.
