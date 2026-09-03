# Mode d'emploi - JWAIO V0.2.1

## 1. Objet de cette version

JWAIO (Jeckyll Widget All in One) est un widget Lua plein écran conçu pour la RadioMaster
TX15 Max sous EdgeTX 2.12.x. Il rassemble les contrôles utiles avant le
décollage, affiche les données essentielles du modèle et enregistre un suivi GPS
sur la carte SD pendant le vol.

La V0.2.1 ajoute les distances GPS au profil LiHv, aux annonces vocales et à
Qwad Finder déjà intégrés. Elle conserve le socle nettoyé et validé
avec les capteurs `RxBt`, `RQly`, `GPS`, `GSpd`, `Alt` et `Sats`.

## 2. Prérequis

- RadioMaster TX15 Max sous EdgeTX 2.12.x.
- Carte SD fonctionnelle et sauvegardée avant installation.
- Modèle de vol déjà configuré.
- Télémétrie du récepteur et du contrôleur de vol découverte dans EdgeTX.
- Page d'accueil plein écran disponible pour le widget.

Avant d'ajouter le widget, ouvrir la page **Télémétrie** du modèle, alimenter le
drone et lancer **Découvrir de nouveaux capteurs**. Cette étape est indispensable,
car plusieurs capteurs sont volontairement intégrés directement au Lua pour ne
pas dépasser la limite du menu natif.

## 3. Installation

1. Éteindre la radio et sauvegarder le contenu actuel de sa carte SD.
2. Extraire `JWAIO-v0.2.1.zip` à la racine de la carte SD.
3. Vérifier les dossiers suivants :

   ```text
   /WIDGETS/JWAIO/
   /SOUNDS/fr/JWAIO/
   /LOGS/JWAIO/
   ```

4. Remettre la carte SD dans la radio et redémarrer EdgeTX.
5. Créer une page d'accueil plein écran.
6. Ajouter le widget **JWAIO**.
7. Ouvrir les réglages du widget et contrôler les dix options du menu.

## 4. Réglages du menu

EdgeTX 2.11 et versions suivantes autorise au maximum dix options dans le menu
natif d'un widget. La V0.2.1 utilise exactement ces dix emplacements.

| Réglage | Rôle | Valeur par défaut |
|---|---|---|
| BatType | Type de batterie | LiPo, avec choix LiIon ou LiHv |
| Cells | Nombre de cellules | 6S, choix de 1S à 8S |
| LinkType | Type de liaison affiché | ELRS |
| LQ | Source de qualité de liaison | RQly |
| ARM | Switch d'armement | SE actif |
| PreArm | Switch de pré-armement | SF actif |
| Beeper | Switch du beeper | Non défini |
| Flip | Switch Flip over crash | Non défini |
| RTH | Switch Return To Home | Non défini |
| Thr | Source du throttle | CH3 |

Le throttle peut être remplacé par une autre voie pour un pilote en Mode 1 ou
pour un modèle dont l'ordre des voies diffère.

## 5. Capteurs intégrés directement au Lua

Les noms ci-dessous sont configurés dans `/WIDGETS/JWAIO/config.lua` :

| Donnée | Nom attendu dans EdgeTX |
|---|---|
| Tension batterie | RxBt |
| Position | GPS |
| Altitude | Alt |
| Vitesse sol | GSpd |
| Satellites | Sats |
| RSSI secondaire | 1RSS |

Si le modèle utilise un autre nom, renommer le capteur dans EdgeTX ou modifier
la valeur correspondante dans `config.lua`, radio éteinte. Redémarrer ensuite
EdgeTX ou recharger le widget. Les identifiants sont résolus une seule fois au
chargement afin de limiter la charge CPU.

La source du mode de vol est `CH5` par défaut. Sa valeur basse affiche `ANGLE`,
les autres valeurs affichent `ACRO`, et le switch RTH du menu est prioritaire.

## 6. Lecture de l'écran principal

### Colonne gauche

- **MODE DE VOL** : ANGLE en vert, ACRO en orange, RTH en rouge.
- **FLY TIME** : valeur de TIMER 1, affichée en minutes et secondes.
- **FLY TOTAL** : valeur de TIMER 2, affichée en heures, minutes et secondes.
- **GPS** : nombre de satellites et couleur de l'état GPS.
- **DERNIERE POSITION** : latitude et longitude de la dernière position valide.

### Zone centrale

- Logo central du widget.
- État `Ready`, `Pre-Arm` ou `Arm`.
- Colonne gauche : vitesse `GSpd` puis distance actuelle au Home.
- Colonne droite : altitude `Alt` puis distance totale parcourue.
- Throttle en pourcentage avec cinq états PNG.
- Indicateur `REC` rouge lorsqu'un journal de vol est en cours.

### Colonne droite

- Tension par cellule et titre automatique `CELL LIPO`, `CELL LIION` ou
  `CELL LIHV`.
- Liaison `ELRS` ou `TBS_CF`, LQ, RSSI et jauge de qualité.
- États Beeper et Flip.
- Qwad Finder, sa valeur RSSI/LQ et sa jauge de rapprochement.

## 7. États GPS

Les données GPS, Alt, GSpd et Sats sont échantillonnées une fois par seconde,
sur le même rythme que le journal de vol.

| Satellites | Affichage | Couleur |
|---|---|---|
| 0 ou capteur absent | NO_DATA | Gris |
| 1 à 4 | SAT 1 à SAT 4 | Rouge |
| 5 à 7 | SAT 5 à SAT 7 | Orange |
| 8 et plus | SAT 8, SAT 9, etc. | Vert |

Une position n'est retenue comme dernière position utile que si la latitude et
la longitude sont valides et qu'au moins cinq satellites sont disponibles. Une
perte de télémétrie ou une coordonnée `0,0` n'écrase jamais cette position.

Le point Home du calcul de distance est capturé au début du vrai vol. ARM seul
ne suffit pas : le throttle doit dépasser 5 %. La distance actuelle utilise les
coordonnées GPS, tandis que le total intègre `GSpd` toutes les secondes. Une
vitesse résiduelle inférieure à 1 km/h et les sauts GPS impossibles sont ignorés.

## 8. Batterie

La valeur affichée est une tension par cellule. Si `RxBt` fournit la tension du
pack, le widget la divise par le nombre de cellules choisi. Si la source fournit
déjà une valeur compatible avec une cellule, elle est utilisée directement.

| Profil | Avertissement | Urgence |
|---|---:|---:|
| LiPo | 3,60 V/cellule | 3,40 V/cellule |
| LiIon | 3,00 V/cellule | 2,80 V/cellule |
| LiHv | 3,60 V/cellule | 3,40 V/cellule |

Une source absente affiche `NO_DATA`. Elle ne doit pas être confondue avec une
batterie faible. L'alerte faible est confirmée dans le temps puis demandée toutes
les deux secondes tant que la tension reste basse. La file audio espace les
lectures pour empêcher le recouvrement des fichiers. L'alerte critique est
prioritaire.

Lors d'une nouvelle connexion, `Lipo_Liion_Full.wav` est joué si une LiPo ou
LiIon dépasse 4,10 V/cellule. `Lihv_Full.wav` est joué si une LiHv dépasse
4,20 V/cellule; sa tension pleine attendue peut atteindre 4,35 V/cellule. Une
perte de télémétrie de moins de trois secondes ne réarme pas cette annonce.

## 9. Timers radio

- **Fly Time** lit TIMER 1. Le widget remet TIMER 1 à zéro au démarrage
  désarmé et à chaque relâchement du switch ARM.
- **Fly Total** lit TIMER 2 et ne le remet jamais à zéro.

Dans le modèle EdgeTX, configurer TIMER 1 avec le déclencheur correspondant au
vol courant. Configurer TIMER 2 avec le déclencheur souhaité pour le cumul et
activer sa persistance si le total doit survivre à l'arrêt de la radio.

## 10. Journaux GPS sur la carte SD

Le suivi est enregistré ici :

```text
/LOGS/JWAIO/FYYMMDD_HHMMSS.csv
/LOGS/JWAIO/lastpos.txt
/LOGS/JWAIO/lastdistance.txt
```

Le fichier CSV est créé lors du passage de ARM à ON. Une ligne est ajoutée
chaque seconde jusqu'au désarmement. Les colonnes sont :

```text
date,time,lat,lon,altitude,speed,cell_v,distance_home_m,distance_total_m,distance_max_m,lq,sats
```

Si le GPS n'est pas encore prêt au moment de l'armement, le fichier existe quand
même et les champs indisponibles restent vides jusqu'à la réception des données.

`lastpos.txt` contient uniquement :

```text
LAT=...
LON=...
```

Il est réécrit à chaque échantillon du journal lorsqu'une dernière position
valide existe, puis une dernière fois au désarmement. Si deux armements ont lieu
pendant la même seconde, le second CSV reçoit un suffixe `_01`, puis `_02`, afin
de protéger le vol précédent.

`lastdistance.txt` contient :

```text
MAX_DISTANCE_M=...
TOTAL_DISTANCE_M=...
```

Le fichier est protégé pendant les contrôles moteur : un armement avec throttle
inférieur ou égal à 5 % ne le modifie pas. Il est actualisé chaque seconde durant
un vrai vol, au désarmement et juste avant le vrai vol suivant.

Les journaux `.csv` s'ouvrent directement dans Excel ou LibreOffice Calc. Pour
les exploiter dans Open Drone Log, conserver le journal brut et créer une copie
normalisée avec :

```text
python tools/jwaio_to_opendronelog.py "F260903_112000.csv"
```

Le nouveau fichier se termine par `-opendronelog.csv`. Les détails et les
correspondances de colonnes sont décrits dans `docs/OPEN_DRONE_LOG.md`.

## 11. Alertes audio de sécurité

Les alertes restent actives même si l'ancien affichage `SON` a été supprimé. Les
événements simultanés sont conservés dans une file priorisée et dédupliquée.

- Batterie faible : répétition toutes les deux secondes tant que l'état persiste.
- Batterie critique : annonce prioritaire par épisode.
- Mauvaise liaison : LQ inférieur au seuil pendant deux secondes, une annonce.
- GPS perdu : après un fix déjà obtenu et deux secondes de perte en vol.
- Throttle : 95 % ou plus pendant trois secondes, une annonce.
- Altitude : une annonce au-delà de 120 m gagnés depuis l'armement, une fois par
  vol. La référence relative évite une alerte immédiate avec une altitude GPS
  absolue déjà supérieure à 120 m au sol.
- Fix GPS : `Satellite.wav` lors du passage à l'état GPS OK, fixé à cinq
  satellites ou plus dans cette version.
- Activations : ACRO, ANGLE, ARM, PRE-ARM, RTH, Beeper et Flip sont annoncés sur
  leur front d'activation, sans annonce répétée tant que l'état ne change pas.

Les 17 fichiers fournis sont stockés dans `/SOUNDS/fr/JWAIO/`. Ils ont été
contrôlés en WAV PCM mono, 16 bits, 32 kHz. `finder_bip.wav` produit le signal
sonore de Qwad Finder.

## 12. Qwad Finder

Le module s'active si au moins une commande Beeper, Flip ou RTH est active. Il
utilise `1RSS` en priorité et `RQly` comme solution de repli, lisse les variations
du signal, puis transforme la mesure en force de 0 à 100 %. Plus cette force
augmente, plus les bips se rapprochent. Pour éviter un chevauchement avec le WAV
de 0,56 seconde, l'intervalle minimum est fixé à 0,65 seconde.

Le module n'est pas chargé au démarrage. Dès que Beeper, Flip et RTH sont tous
inactifs, JWAIO retire l'instance et demande une collecte mémoire. Les alertes
vocales de sécurité conservent toujours la priorité sur `finder_bip.wav`.

## 13. Procédure de contrôle sans hélices

1. Démarrer sans drone et vérifier `NO_DATA` pour les données absentes.
2. Allumer le drone et attendre l'arrivée de RxBt, RQly, GPS, Alt, GSpd et Sats.
3. Vérifier ANGLE, ACRO et RTH.
4. Vérifier Ready, Pre-Arm et Arm.
5. Vérifier Beeper et Flip.
6. Armer : `REC` doit apparaître et un CSV doit être créé.
7. Désarmer : Fly Time doit revenir à `00:00`; Fly Total doit rester inchangé.
8. Contrôler `lastpos.txt` et le CSV sur la carte SD.
9. Tester les profils LiPo, LiIon et LiHv sans utiliser une batterie en condition
   dangereuse : simuler les valeurs dans EdgeTX ou utiliser le mode démo.
10. Actionner séparément ACRO, ANGLE, ARM, PRE-ARM, RTH, Beeper et Flip, puis
    vérifier qu'une seule annonce est jouée par activation.

11. Activer Beeper, Flip puis RTH séparément : Qwad Finder doit apparaître et
    ses bips doivent accélérer quand `1RSS` devient moins négatif.
12. Couper les trois commandes : le panneau doit revenir à `OFF`.
13. Vérifier les colonnes Speed/Dist et Alt/Total avec un GPS valide.
14. Faire un armement de contrôle sous 5 % : `lastdistance.txt` doit rester intact.

## 14. Dépannage

### NO_DATA reste affiché

- Relancer la découverte des capteurs avec le drone alimenté.
- Vérifier l'orthographe exacte du capteur dans EdgeTX.
- Recharger le widget après une découverte ou une modification de `config.lua`.

### La vitesse reste absente

Le capteur testé est `GSpd`, pas `VSpd`. Vérifier qu'il est présent et exprimé en
km/h. Le multiplicateur est réglé à `1.0` dans `config.lua`.

### Fly Time ne démarre pas

Vérifier la configuration de TIMER 1 dans le modèle et le switch ARM choisi dans
le menu du widget.

### LOG OPEN, LOG WRITE ou LOG APPEND

Vérifier la présence et l'état de `/LOGS/JWAIO/`, l'espace libre et l'intégrité
de la carte SD. Éteindre la radio avant de retirer la carte.

## 15. Personnaliser le logo central

Le logo affiché par le widget est indépendant du logo de présentation du projet.
Pour utiliser son propre visuel :

1. préparer un PNG **RGBA avec transparence** de **216 × 132 pixels** ;
2. le nommer exactement `logo.png` ;
3. radio éteinte, remplacer `/WIDGETS/JWAIO/img/logo.png` ;
4. redémarrer EdgeTX ou recharger complètement le widget.

Le chargement et le centrage sont automatiques. Un fichier plus grand augmente
inutilement la consommation de mémoire ; un fichier d'une autre taille peut être
redimensionné à l'écran et perdre en netteté. L'utilisateur doit posséder les
droits nécessaires sur le visuel installé.

## 16. Limites de la V0.2.1

- Cible unique TX15 Max / EdgeTX 2.12.x.
- Utilisation prévue en plein écran 480 x 320.
- Les sons fournis sont intégrés, mais leur volume et leur formulation restent à
  valider en situation réelle.
- Qwad Finder donne une indication relative : le niveau dépend de la puissance
  d'émission, de l'antenne, de l'orientation et des obstacles.
- La distance totale est une estimation GPS ; sa précision dépend de `GSpd`, du
  rythme télémétrique et de la qualité du fix.
- Qwad Finder est une aide relative et ne remplace pas un buzzer autonome, un
  GPS fiable ou une balise dédiée.

Cette version est destinée aux essais réels de Qwad Finder et des distances GPS.
