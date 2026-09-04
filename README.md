# JWAIO — Jeckyll Widget All in One

JWAIO est un widget Lua FPV plein écran ou mode app conçu pour la **RadioMaster TX15 Max**
sous **EdgeTX 2.12.x**. Il rassemble les contrôles avant décollage, les alertes
sonores essentielles, le suivi GPS et un **Qwad Finder** basé sur la puissance du
signal reçu.

Version actuelle : **0.2.1 — version d'essai**.

![Interface finale JWAIO sur RadioMaster TX15 Max](docs/assets/jwaio-tx15-interface-final.jpg)

> JWAIO assiste le pilote mais ne remplace ni les vérifications de sécurité,
> ni l'OSD vidéo, ni un dispositif de localisation autonome.

## Fonctions principales

- Affichage Modes `ANGLE`, `ACRO` et `RTH`, avec états `Ready`, `Pre-Arm` et `Arm`.  
--| effet sonore pour chaque mode engagé.

- Affichage Throttle en pourcentage et cinq états graphiques PNG.
--| effet sonore si Throttle 100% > a 3s [ protection esc ]

- `Fly Time` lu depuis TIMER 1 et `Fly Total` depuis TIMER 2  
--| A configurer dans Betaflight.

- Batteries LiPo, LiIon et LiHv, tension par cellule.
--| Effet sonore si batterie engager Full.
--| Effet sonore si batterie faible en fonction du choix de la batterie posé sur la machine.
--| Effet sonore si batterie critique en fonction du choix de la batterie posé sur la machine.

- Affichage Fixe Satellites, position gps.
--| Effet sonore si 5 satellite fixé.
--| Sauvegarde de la dernière position Gps.

- Liaison ELRS ou TBS Crossfire avec LQ, RSSI et jauge de qualité.
--| Effet sonore si LQ < 70%.

- Sauvegarde des valeurs GPS, satellites, dernière position, vitesse et altitude à 1 Hz dans un fichier CSV
à des fins d'exploitation.

- Exploitation du fichier grâce au logiciel gratuit libre de droit ou appli web [https://opendronelog.com/](https://app.opendronelog.com/)

- Affichage Distance au Home, distance maximale et trajet total estimé.

- Qwad Finder chargé uniquement lorsque Beeper, Flip ou RTH est actif.
--| Effet sonore lors de l'approche de la machine perdu.

## Installation rapide

Avant toute manipulation, sauvergarder votre config radio grace a l'appli [EdgeBuddi](https://buddy.edgetx.org/#/flash?version=v2.11.4&source=releases)
--| Supprimer l'integration des sons de vos switchs sur votre radio, pour eviter tout risque de superposition.
--| Si vous avez déjà programmer un Log auto sur votre radio, il faudra le couper pour éviter un double enregistrement.

1. Télécharger `JWAIO-v0.2.1.zip` depuis la future page **Releases**.
2. Sauvegarder le contenu de votre carte SD
3. Extraire le contenu du ZIP à sa racine.
4. Découvrir les capteurs avec le drone alimenté.
5. Redémarrer EdgeTX et ajouter **JWAIO** sur une page plein écran.
|-- Il est possible de faire une page Appli.
6. Choisir la batterie, les switches et les sources dans les réglages du widget.
7. Have fun

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

## Les Capteurs

Pour respecter mon script lors, plusieurs capteurs sont lus directement par leur nom :
Ce widget a besoin de :

| Donnée | Nom EdgeTX attendu |
|---|---|
| Batterie | `RxBt` |
| GPS | `GPS` |
| Altitude | `Alt` |
| Vitesse sol | `GSpd` |
| Satellites | `Sats` |
| RSSI Finder | `1RSS` |
| Link quality | `RQly` |

Les noms sont modifiables dans `sdcard/WIDGETS/JWAIO/config.lua`.

## Les Switchs

Choisir dans le menu les switch associer au focntion du script :

| Switch |
|---|---|
| Arm |
| Pré-arm |
| Beeper |
| Flip |
| RTH |
| Thr |

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
FB -> https://www.facebook.com/
Yb -> https://www.youtube.com/@JeckyllHydeFpv
