# JWAIO Boxer v0.2.1 Alpha [ FREESTYLE EDITION ]

**Script FPV dédié à la RadioMaster Boxer et à son écran monochrome 128 × 64 pixels.**

J'ai créé JWAIO Boxer pour retrouver l'esprit de JWAIO sur une radio qui ne peut pas utiliser le widget couleur des TX15 et TX16S. Cette interface **TOOLS** privilégie les informations essentielles au freestyle, sans affichage GPS.

![Écran d'accueil réel de JWAIO Boxer](boxer/assets/screens/10-accueil.jpg)

## Télécharger

| Radio | EdgeTX | Version | Archive |
|---|---|---|---|
| RadioMaster Boxer | 2.12.2 | v0.2.1 Alpha | [Télécharger JWAIO Boxer](https://raw.githubusercontent.com/DrJeckyllMrHyde/JWAIO-EdgeTX/boxer/boxer/releases/JWAIO_BOXER_V0.2.1_Alpha.zip) |

[Vérifier l'empreinte SHA-256](https://raw.githubusercontent.com/DrJeckyllMrHyde/JWAIO-EdgeTX/boxer/boxer/releases/SHA256SUMS.txt)

## État de la version

Les essais sur RadioMaster Boxer ont confirmé :

- le bon fonctionnement de toutes les interfaces ;
- l'absence de gel pendant les essais réalisés sans connexion USB ;
- l'audibilité des seize sons fournis ;
- l'affichage de tous les réglages disponibles.

Le correctif du 1er novembre 2026 réduit les allocations audio et les accès inutiles à la carte SD. Il conserve également les statistiques après un refus d'écriture et effectue jusqu'à trois nouvelles tentatives espacées. Les simulations d'endurance sont positives ; ce correctif doit encore être confirmé sur la radio ayant signalé le gel du bilan.

L'ensemble des fonctions en vol reste à valider. Cette version conserve donc le statut **Alpha**.

## Fonctions principales

- contrôle avant vol avec tension par cellule et liaison ELRS ;
- écran de vol avec batterie, chronomètre, LQ et mesures radio ;
- bilan après le désarmement ;
- QWAD Finder fondé sur l'évolution du signal et des bips ;
- alertes de batterie et de télémétrie ;
- annonces sonores configurables ;
- journal CSV sans GPS sur la carte SD ;
- réglages et compteurs sauvegardés par modèle.

Les indications ARM, Angle, BlackBox, Failsafe ou RTH correspondent aux commandes lues sur la radio. Elles ne modifient jamais les mixages et ne constituent pas des confirmations du contrôleur de vol.

## Installation et documentation

- **[Installer JWAIO Boxer pas à pas](boxer/docs/INSTALLATION.md)**
- [Comprendre les écrans et les fonctions](boxer/docs/FONCTIONS.md)
- [Consulter la compatibilité et l'état des essais](boxer/docs/VALIDATION.md)
- [Lire les notes de version](boxer/CHANGELOG.md)
- [Voir le contenu du paquet](boxer/releases/README.md)

L'installation consiste à copier les dossiers `LOGS`, `SCRIPTS` et `SOUNDS` à la racine de la carte SD après avoir choisi **USB Storage (SD)** sur la radio. Le guide illustré détaille chaque étape.

## Autres versions de JWAIO

Le widget couleur pour TX15/TX16S, la galerie de skins et JWAIO Cleaner restent disponibles sur la [branche principale du projet](https://github.com/DrJeckyllMrHyde/JWAIO-EdgeTX/tree/main).
