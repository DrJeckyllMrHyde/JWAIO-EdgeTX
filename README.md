# JWAIO — Jeckyll Widget All in One

JWAIO est un widget Lua FPV plein écran conçu pour la **RadioMaster TX15 Max**
sous **EdgeTX 2.12.x**. Il rassemble les contrôles avant décollage, les alertes
sonores essentielles, le suivi GPS et un **Qwad Finder** basé sur la puissance du
signal reçu.

Version actuelle : **0.2.1 — version d'essai**.

![Interface finale JWAIO sur RadioMaster TX15 Max](docs/assets/jwaio-tx15-interface-final.jpg)

> JWAIO assiste le pilote mais ne remplace ni les vérifications de sécurité,
> ni l'OSD vidéo, ni un dispositif de localisation autonome.

## Fonctions principales

- Modes `ANGLE`, `ACRO` et `RTH`, avec états `Ready`, `Pre-Arm` et `Arm`.
- Throttle en pourcentage et cinq états graphiques PNG.
- `Fly Time` lu depuis TIMER 1 et `Fly Total` depuis TIMER 2.
- Batteries LiPo, LiIon et LiHv, tension par cellule et distinction `NO_DATA`.
- Alertes vocales de batterie, liaison, GPS, altitude, throttle et switches.
- Liaison ELRS ou TBS Crossfire avec LQ, RSSI et jauge de qualité.
- GPS, satellites, dernière position, vitesse et altitude à 1 Hz.
- Distance au Home, distance maximale et trajet total estimé.
- Un journal CSV par armement, plus sauvegarde de la dernière position et des
  distances du dernier vrai vol.
- Qwad Finder chargé uniquement lorsque Beeper, Flip ou RTH est actif ; ses bips
  accélèrent à l'approche du quad.

## Installation rapide

1. Télécharger `JWAIO-v0.2.1.zip` depuis la future page **Releases**.
2. Sauvegarder la carte SD puis extraire le ZIP à sa racine.
3. Découvrir les capteurs avec le drone alimenté.
4. Redémarrer EdgeTX et ajouter **JWAIO** sur une page plein écran.
5. Choisir la batterie, les switches et les sources dans les réglages du widget.

Les dossiers installés sont :

```text
/WIDGETS/JWAIO/
/SOUNDS/fr/JWAIO/
/LOGS/JWAIO/
```

Consulter le [mode d'emploi rapide](MODE_EMPLOI.txt), le
[mode d'emploi détaillé](docs/MODE_EMPLOI.md) et le
[guide d'installation](docs/INSTALLATION.md). La
[présentation synthétique au format PDF](output/pdf/JWAIO-Presentation-v0.2.1.pdf)
résume les fonctions essentielles du projet en 6 pages.

## Capteurs attendus

Pour respecter la limite de dix réglages du menu EdgeTX, plusieurs capteurs sont
lus directement par leur nom :

| Donnée | Nom EdgeTX attendu |
|---|---|
| Batterie | `RxBt` |
| GPS | `GPS` |
| Altitude | `Alt` |
| Vitesse sol | `GSpd` |
| Satellites | `Sats` |
| RSSI Finder | `1RSS` |

Les noms sont modifiables dans `sdcard/WIDGETS/JWAIO/config.lua`.

## Journaux et Open Drone Log

Les journaux sont des fichiers CSV lisibles dans Excel ou LibreOffice Calc. Le
convertisseur `tools/jwaio_to_opendronelog.py` produit un fichier conforme aux
colonnes attendues par Open Drone Log sans modifier l'original :

```text
python tools/jwaio_to_opendronelog.py "F260903_112000.csv"
```

Voir [Utiliser JWAIO avec Open Drone Log](docs/OPEN_DRONE_LOG.md). Open Drone Log
est un [projet gratuit et open source](https://opendronelog.com/) indépendant de
JWAIO.

## Personnaliser le logo de la radio

Remplacer `sdcard/WIDGETS/JWAIO/img/logo.png` par un fichier :

- nommé exactement `logo.png` ;
- au format PNG RGBA avec transparence ;
- de **216 × 132 pixels**.

Effectuer le remplacement radio éteinte, puis redémarrer EdgeTX ou recharger
complètement le widget. L'utilisateur reste responsable des droits du visuel.

## Développement et vérification

Les outils de construction sont dans `tools/`. Le projet vérifie notamment la
structure de la carte SD, les dix options du menu, les WAV, les PNG et la syntaxe
des modules Lua. Le test du convertisseur s'exécute avec :

```text
python tests/test_opendronelog_converter.py
```

## Licences et attribution

- Code source : [Apache License 2.0](LICENSE).
- Documentation, logo de projet et sons originaux :
  [Creative Commons Attribution 4.0](LICENSE-ASSETS.md).
- Crédits : [AUTHORS.md](AUTHORS.md) et [NOTICE](NOTICE).
- Composants tiers : [sdcard/THIRD_PARTY_NOTICES.txt](sdcard/THIRD_PARTY_NOTICES.txt).

Copyright © 2026 **DrJeckyllMrHyde**.
