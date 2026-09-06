JWAIO - JECKYLL WIDGET ALL IN ONE - V0.2.1

Installation : extraire ce ZIP a la racine de la carte SD.

Puis :
1. Redemarrer EdgeTX.
2. Ajouter le widget JWAIO sur une page plein ecran.
3. Ouvrir ses reglages et selectionner les sources et switches.

Points de controle V0.2.1 :
- Fly Time reprend le TIMER 1 de la radio.
- Fly Total reprend le TIMER 2 de la radio.
- BatType permet de choisir LiPo, LiIon ou LiHv.
- LinkType permet de choisir ELRS ou TBS_CF.
- Cells est configure a 6S par defaut.
- Decouvrir RxBt, GPS, Alt, GSpd et Sats avant d'ajouter le widget.
- GPS : 1-4 satellites rouge, 5-7 orange, 8 et plus vert.
- GPS, Alt, GSpd et Sats sont lus toutes les secondes.
- Relacher ARM remet Fly Time/TIMER 1 a zero, sans toucher TIMER 2.
- Deux armements dans la meme seconde creent deux journaux distincts.
- Les annonces modes, switches, batterie pleine, satellite et altitude sont actives.
- L'alerte altitude utilise Alt valide > 120 m, une fois par armement.
- Revision finale du 06/09/2026 : alertes batterie sans repetition incessante,
  sons alleges et Finder plus reactif, prioritaire pendant la recherche.
- Les champs CSV des capteurs invalides restent vides.
- L'alerte throttle se declenche apres 3 secondes a 95 % ou plus.
- Qwad Finder s'active avec Beeper, Flip ou RTH.
- Le bip de recherche accelere lorsque le RSSI recu devient plus fort.
- Le finder est libere lorsque Beeper, Flip et RTH sont tous desactives.
- Speed/Dist sont affiches a gauche et Alt/Total a droite, sans cadre.
- Le calcul de distance commence seulement avec ARM et throttle superieur a 5 %.
- Un controle moteur a 5 % ou moins conserve le resultat du dernier vrai vol.

Chemins principaux :
/WIDGETS/JWAIO/
/SOUNDS/fr/JWAIO/
/LOGS/JWAIO/

Fichiers GPS :
/LOGS/JWAIO/FYYMMDD_HHMMSS.csv
/LOGS/JWAIO/lastpos.txt
/LOGS/JWAIO/lastdistance.txt

Cette version contient des sons WAV de test. Consulter la documentation du projet
avant de tester les alertes avec les helices montees.
