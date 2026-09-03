# Installation et premier essai sur TX15 Max

## Préparation

- RadioMaster TX15 Max
- EdgeTX 2.12.x
- carte SD montée et accessible
- modèle configuré avec télémétrie découverte

La dalle réelle de la TX15 Max est de 480 x 320 pixels. Le widget utilise cette
base et adapte automatiquement le layout à la zone fournie par EdgeTX.

## Installation

1. Sauvegarder le contenu actuel de la carte SD.
2. Extraire `JWAIO-v0.2.1.zip` à la racine de la carte.
3. Vérifier la présence de :

   ```text
   /WIDGETS/JWAIO/main.lua
   /SOUNDS/fr/JWAIO/
   /LOGS/JWAIO/
   ```

4. Redémarrer la radio.
5. Sur l'écran d'accueil, créer une page plein écran et sélectionner **JWAIO**.

## Réglages du widget

Le menu natif EdgeTX expose dix réglages :

| Réglage | Fonction | Valeur conseillée |
|---|---|---|
| BatType | Chimie de la batterie | LiPo, LiIon ou LiHv |
| Cells | Nombre de cellules | 6 par défaut, choix 1 à 8 |
| LinkType | Protocole affiché | ELRS ou TBS_CF |
| LQ | Qualité de liaison | RQly par défaut ou autre capteur |
| ARM | Switch d'armement | position active de SE |
| PreArm | Switch de pré-armement | position active de SF |
| Beeper | Switch Beeper | selon le modèle |
| Flip | Switch Flip over crash | selon le modèle |
| RTH | Switch Return To Home | selon le modèle |
| Thr | Source throttle | CH3 par défaut, modifiable |

Avant d'ajouter le widget, lancer **Découvrir de nouveaux capteurs** dans EdgeTX.
Le Lua utilise directement les noms suivants :

| Donnée | Nom attendu |
|---|---|
| Batterie | RxBt |
| Coordonnées | GPS |
| Altitude | Alt |
| Vitesse | GSpd |
| Satellites | Sats |

Si le modèle emploie un autre nom, il faut le renommer dans EdgeTX ou modifier la
valeur correspondante dans `/WIDGETS/JWAIO/config.lua` avant d'ajouter le widget.
La valeur `GSpd` est déjà fournie en km/h sur le modèle testé.

Le bloc GPS utilise les couleurs suivantes :

- 0 satellite ou capteur absent : `NO_DATA` gris ;
- 1 à 4 satellites : rouge ;
- 5 à 7 satellites : orange ;
- 8 satellites et plus : vert.

GPS, Alt, GSpd et Sats sont actualisés une fois par seconde. Les coordonnées sont
affichées dans `DERNIERE POSITION` dès que le GPS est valide avec au moins cinq
satellites, puis conservées si le signal disparaît.

Si un capteur est absent ou mal sélectionné, le widget doit afficher `NO_DATA`.
Une valeur nulle ne doit pas être présentée comme une batterie faible.

Les profils LiPo et LiHv avertissent sous 3,60 V/cellule et passent en critique
sous 3,40 V. Le profil LiIon avertit sous 3,00 V/cellule et passe en critique
sous 2,80 V.

Au branchement, une LiPo ou LiIon au-dessus de 4,10 V/cellule déclenche
`Lipo_Liion_Full.wav`. Une LiHv au-dessus de 4,20 V/cellule déclenche
`Lihv_Full.wav`; sa tension pleine attendue peut atteindre 4,35 V/cellule.

## Réglages avancés V0.1

Les choix suivants sont centralisés dans `/WIDGETS/JWAIO/config.lua` :

- source du mode de vol, CH5 par défaut ;
- sources GPS, satellites et RSSI secondaire ;
- seuils batterie et LQ ;
- durée de protection throttle ;
- noms et extension des fichiers audio ;
- sources altitude et vitesse, ainsi que calcul des distances GPS ;
- mode de démonstration.

Le mode ANGLE/ACRO utilise la source définie dans `config.lua`. Le switch RTH du
menu reste prioritaire :

```text
valeur basse       -> ANGLE
autre valeur       -> ACRO
switch RTH actif   -> RTH
```

## Séquence de test recommandée

1. Démarrer sans le drone : vérifier `NO_DATA` pour batterie, liaison, GPS,
   vitesse et altitude, sans fausse alerte.
2. Allumer le drone : vérifier l'arrivée de RxBt, LQ et GPS.
3. Tester chaque position du mode de vol.
4. Vérifier Beeper et Flip sans hélices.
5. Armer sans hélices : un fichier CSV doit apparaître dans `/LOGS/JWAIO/`.
6. Régler TIMER 1 et TIMER 2 dans le modèle EdgeTX, puis vérifier leurs valeurs.
7. Relâcher ARM : Fly Time/TIMER 1 doit revenir à `00:00`, Fly Total/TIMER 2 ne
   doit pas être remis à zéro.
8. Passer entre LiPo, LiIon et LiHv : vérifier le titre, les seuils et les couleurs.
9. Passer de ELRS à TBS_CF : vérifier le titre du bloc et l'absence de superposition.
10. Activer RTH : le bloc mode de vol doit afficher `RTH`.
11. Vérifier les deux colonnes centrales : Speed/Dist à gauche et Alt/Total à droite.
12. Armer avec un throttle inférieur ou égal à 5 %, puis désarmer : les distances
    du dernier vol ne doivent pas être remises à zéro.
13. Armer et dépasser 5 % : un nouveau calcul doit commencer à zéro.

## Audio

Les 17 fichiers fournis sont des WAV PCM mono, 32 kHz, 16 bits. Les annonces
suivantes sont intégrées : ACRO, ANGLE, ARM, PRE-ARM, RTH, Beeper, Flip, fix GPS,
altitude, batterie pleine, batterie faible, batterie critique, liaison, perte GPS
et throttle. `finder_bip.wav` est utilisé par Qwad Finder.

Qwad Finder s'active si Beeper, Flip ou RTH est actif. Il affiche `1RSS` en dBm,
avec `RQly` comme repli, puis réduit l'intervalle entre les bips lorsque la force
reçue augmente. Les annonces de sécurité restent prioritaires.

L'annonce d'altitude est jouée une seule fois par vol lorsque le gain depuis
l'altitude mesurée à l'armement dépasse 120 m. Cette référence relative évite une
fausse annonce immédiate lorsque `Alt` fournit une altitude absolue au-dessus du
niveau de la mer.

## Journaux

Un CSV est créé à chaque armement :

```text
date,time,lat,lon,altitude,speed,cell_v,distance_home_m,distance_total_m,distance_max_m,lq,sats
```

La dernière position valide est aussi conservée dans `lastpos.txt`. Une perte GPS
ou une coordonnée `0,0` ne doit jamais écraser cette position.

`lastdistance.txt` conserve la distance maximale au Home et la distance totale
du dernier vrai vol. Il est actualisé chaque seconde en vol, au désarmement et
avant la remise à zéro déclenchée par le prochain dépassement de 5 % de throttle.

Les fichiers sont enregistrés dans :

```text
/LOGS/JWAIO/FYYMMDD_HHMMSS.csv
/LOGS/JWAIO/lastpos.txt
/LOGS/JWAIO/lastdistance.txt
```

Si deux armements ont lieu dans la même seconde, le second fichier reçoit un
suffixe (`_01`, `_02`, etc.) afin de ne pas écraser le vol précédent.

La V0.2.1 utilise l'API fichier simplifiée d'EdgeTX (`io.write`, `io.read` et
`io.close`). Cette correction remplace les méthodes Lua standard non disponibles
sur la radio et supprime l'erreur observée lors de l'armement.
