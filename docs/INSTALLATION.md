# Installer JWAIO v0.3.1 — guide débutant

## 1. Choisir la bonne archive

Commencez par le [tableau de téléchargement](../README.md). TX15/TX15 Max, TX16S Mk1/Mk2 et TX16S Mk3 ont chacun leur paquet. N'installez pas les trois : ils utilisent tous le nom JWAIO et les mêmes dossiers.

TX15 et Mk1/Mk2 ont été testés et sont fonctionnels pour tous les usages selon le créateur ; des correctifs mineurs/optimisations restent possibles. La Mk3 a été adaptée aux spécifications RadioMaster sans radio physique : elle reste à tester. EdgeTX 2.12.0 ou supérieur est requis ; la série visée par les archives est 2.12.x. Consultez les [précisions de compatibilité](COMPATIBILITE.md), notamment pour la notice Mk3.

Le téléchargement général du dépôt et son ancien dossier `sdcard/` ne sont pas les paquets v0.3.1. Les ZIP fournis contiennent le widget et ses médias, pas un firmware à flasher.

## 2. Préparer et sauvegarder

Prévoyez un ordinateur, un câble USB de données et un modèle EdgeTX déjà configuré pour votre véhicule. Sauvegardez le stockage et les paramètres du modèle avant de remplacer des fichiers. Conservez une copie de `/WIDGETS/JWAIO/config.lua`, de vos skins et de `/LOGS/JWAIO/` si JWAIO est déjà installé.

Pour les vérifications avec le véhicule alimenté, retirez les hélices. Le widget n'effectue pas la configuration du récepteur ou du contrôleur de vol.

## 3. Décompresser sur l'ordinateur

Ouvrez le ZIP et extrayez ses fichiers dans un dossier de votre ordinateur.

| Archive | Où trouver les dossiers à copier |
|---|---|
| TX15 | Directement dans le dossier extrait |
| TX16S Mk1/Mk2 | Ouvrez `JWAIO-v0.3.1_TX16S-Mk1-Mk2` dans le dossier extrait |
| TX16S Mk3 | Directement dans le dossier extrait ; les notices supplémentaires restent consultables sur l'ordinateur |

Vous devez voir ensemble **WIDGETS**, **SOUNDS** et **LOGS**. L'archive TX15 contient aussi un dossier `SCRIPTS/TOOLS` vide ; il n'est pas nécessaire pour ajouter ce widget.

## 4. Copier vers le stockage EdgeTX

1. Allumez la radio, branchez son port USB de données et choisissez **USB Storage / Stockage USB** si ce choix apparaît.
2. Dans l'explorateur de fichiers, ouvrez le volume où EdgeTX lit ses dossiers `WIDGETS` et `SOUNDS`. Selon la radio et sa configuration, il peut s'agir du stockage interne ou de la microSD. Si plusieurs volumes apparaissent, repérez les dossiers EdgeTX existants ; ne copiez pas les fichiers au hasard sur tous les volumes.
3. Copiez **WIDGETS, SOUNDS et LOGS** depuis le paquet dans ce volume. La « racine » est le premier niveau du volume, avant d'ouvrir un sous-dossier.
4. Acceptez la fusion des dossiers. Lors d'une mise à jour, remplacez les fichiers JWAIO de la version précédente après sauvegarde. Conservez les journaux et les fichiers des autres widgets.
5. Éjectez proprement le lecteur depuis l'ordinateur, débranchez le câble puis redémarrez la radio.

Chemins finaux attendus :

```text
Racine du stockage EdgeTX/
├── WIDGETS/
│   └── JWAIO/
│       ├── main.lua
│       ├── config.lua
│       ├── lib/
│       ├── img/
│       └── skins/
├── SOUNDS/
│   └── fr/
│       └── JWAIO/
│           └── fichiers .wav
└── LOGS/
    └── JWAIO/
        └── README.txt
```

Correct : `/WIDGETS/JWAIO/main.lua`.
Incorrect : `/JWAIO-v0.3.1_TX16S-Mk1-Mk2/WIDGETS/JWAIO/main.lua`.

## 5. Découvrir les capteurs

Sélectionnez le bon modèle sur la radio. Avec le véhicule alimenté et connecté, ouvrez la page **Télémétrie** du modèle, lancez **Découvrir de nouveaux capteurs**, attendez leur apparition puis arrêtez la découverte. Le libellé exact des menus dépend de la langue d'EdgeTX.

Vérifiez notamment RxBt (batterie du véhicule), RQly (LQ) et 1RSS (RSSI). Avec un GPS, les noms attendus sont GPS, Alt, GSpd et Sats. N'inventez pas de valeurs pour les capteurs absents. Si votre installation utilise d'autres noms, consultez le [mode d'emploi](MODE_EMPLOI.md).

Après ajout ou modification des capteurs, redémarrez EdgeTX ou recréez l'instance du widget afin qu'il retrouve les capteurs.

## 6. Ajouter le widget à l'écran

Depuis l'écran principal, ouvrez le menu de configuration de l'affichage, généralement **Configurer écrans / Setup screens**. Choisissez un écran avec une seule grande zone, sélectionnez cette zone puis le widget **JWAIO**. Ouvrez ensuite ses options. Une seule instance JWAIO par modèle évite les doublons de sons et de gestion des minuteries.

Privilégiez le plein écran : TX15 480 × 320, Mk1/Mk2 480 × 272, Mk3 800 × 480. Le portage Mk1/Mk2 demande une zone d'au moins 360 × 220 ; celui de la Mk3 au moins 600 × 380. Si la radio affiche un avertissement de zone trop petite, agrandissez la zone et réduisez les éléments d'affichage qui l'occupent.

Réglez **BatType** et **Cells** pour votre batterie, puis **ARM, PreArm, Beeper, Flip, RTH et Thr** selon les commandes déjà configurées dans le modèle. Ne conservez pas un interrupteur par défaut sans le vérifier. Le [tableau des dix options](MODE_EMPLOI.md) explique chaque choix.

## 7. Première vérification

- La tension et le nombre de cellules correspondent à la batterie du véhicule.
- L'état ARM/PreArm suit vos commandes ; la jauge des gaz correspond à la voie choisie.
- LQ/RSSI sont présents lorsque la liaison fournit ces données.
- Les champs GPS sont cohérents si le matériel est équipé ; sans GPS, `NO_DATA` est normal pour les données absentes.
- Les minuteries suivent la condition de marche configurée dans EdgeTX.
- Les annonces sont audibles et ne sont pas dupliquées par d'autres fonctions EdgeTX.
- Le Finder démarre et s'arrête avec les commandes affectées ; pendant son fonctionnement les autres alertes JWAIO ne sont pas disponibles normalement.

Pour Mk3, suivez en plus la [fiche de retour d'essais](TESTS_TX16_MK3.md).

## Mettre à jour une installation existante

Après sauvegarde, recopiez le paquet correspondant à votre radio. Ne remettez pas l'ancien `config.lua` entier sur le nouveau : reportez seulement vos personnalisations nécessaires dans le fichier v0.3.1. Restaurez vos skins personnels sans écraser le skin de secours JWAIO fourni.

Si l'ancien menu ne contenait pas **Skin**, retirez l'instance JWAIO de la page puis ajoutez-la de nouveau. Sinon vous pouvez conserver l'instance, en contrôlant toutes les options. En cas de changement de variante ou de problème de configuration, recréez l'instance après avoir noté vos réglages.

## Dépannage rapide

| Symptôme | Vérification |
|---|---|
| JWAIO absent de la liste | Chemin `/WIDGETS/JWAIO/main.lua`, bon volume, ZIP décompressé, puis redémarrage |
| Erreur Lua ou fichier absent | Recopier le paquet complet de la bonne radio ; relever le message exact si l'erreur persiste |
| Affichage coupé ou zone trop petite | Une seule grande zone et bonne variante radio |
| `NO_DATA` | Liaison, alimentation du véhicule, découverte et noms des capteurs ; redémarrer après modification |
| Mauvaise batterie ou faux seuils | BatType, Cells et origine du capteur RxBt |
| Pas de sons | Volume radio, fichiers `.wav` dans `/SOUNDS/fr/JWAIO/`, Finder inactif lors du contrôle des autres annonces |
| Mauvais mode ANGLE/ACRO | SA bas est la commande par défaut ; voir `modeSource` et `modeAnglePosition` |
| Temps de vol immobile | Condition de marche des TIMER 1 et TIMER 2 dans EdgeTX |
| Finder actif en permanence | Affectations Beeper/Flip/RTH ; leurs trois positions doivent être inactives pour quitter la recherche |

## Désinstaller

**Windows 10/11 :** [JWAIO Cleaner](CLEANER.md) est en préparation, avec conservation des skins et des logs et confirmation avant suppression. **La release reste en brouillon pendant l'examen des alertes antivirus** ; consultez les [rapports complets](CLEANER-ANTIVIRUS.md). Utilisez la procédure manuelle ci-dessous pour le moment.

Sauvegardez vos skins et journaux, retirez JWAIO des écrans de chaque modèle concerné, puis supprimez uniquement `/WIDGETS/JWAIO/` et `/SOUNDS/fr/JWAIO/`. Vous pouvez conserver `/LOGS/JWAIO/` pour garder vos vols. Éjectez proprement le stockage et redémarrez. Ne supprimez pas les dossiers parents WIDGETS, SOUNDS ou LOGS, qui peuvent servir à d'autres fonctions.
