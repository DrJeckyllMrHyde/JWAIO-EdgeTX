# Notes de version JWAIO Boxer

## Correctif bilan et sauvegarde — 1er novembre 2026

- Réduction des allocations répétées dans la gestion audio.
- Suppression de l'ouverture des fichiers WAV par Lua pour vérifier leur présence.
- Suppression de la collecte mémoire complète forcée avant chaque sauvegarde.
- Conservation des statistiques en mémoire après un refus d'écriture sur la carte SD.
- Jusqu'à trois tentatives automatiques de sauvegarde, espacées d'au moins cinq secondes.
- Tests d'endurance réussis sur ordinateur : deux bilans simulés de quinze minutes et quinze minutes de refus SD.

## v0.2.1 Alpha — 31 octobre 2026

- Interface FPV dédiée à la RadioMaster Boxer et à son écran monochrome 128 × 64.
- Script accessible depuis **SYS → TOOLS → JWAIO Boxer** sous EdgeTX 2.12.2.
- Écrans d'accueil, avant vol, vol, bilan, Finder, batterie critique et perte de télémétrie.
- Réglages des cellules, de la batterie, du capteur, du seuil critique, des commandes, des sons et du journal SD.
- Sauvegarde des réglages et compteurs par modèle dans deux copies vérifiées.
- Journaux CSV sans GPS dans `/LOGS/JWBOX/`.
- Six scripts Lua et seize sons WAV inclus dans l'archive.
- Correctif testé sur RadioMaster Boxer : démarrage et sons audibles confirmés hors USB.
- Statut Alpha conservé pendant la poursuite des essais complets en vol.
