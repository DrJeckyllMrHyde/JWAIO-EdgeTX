# Utiliser JWAIO 0.3_Alpha

Le [guide d'installation](INSTALLATION.md) et le [mode d'emploi simple](../MODE_EMPLOI.txt) décrivent la mise en place et la suppression.

## Réglages

Le menu contient dix options : **Skin, BatType, Cells, LinkType, ARM, PreArm, Beeper, Flip, RTH, Thr**.
Les capteurs sont lus par leur nom dans `config.lua` : RxBt, RQly, 1RSS, GPS, Alt, GSpd, Sats.
Découvrez-les dans EdgeTX avant de charger le widget. Pour le freestyle sans GPS, les champs correspondants restent indisponibles sans bloquer batterie et liaison.

JWAIO ne configure pas les fonctions du contrôleur de vol : il surveille les commandes configurées dans votre modèle. Le mode ANGLE est lu sur la position basse de CH5 par défaut, ACRO sinon ; le switch RTH choisi prend priorité.

## Batteries

| Profil | Alerte basse | Critique | Annonce pleine |
|---|---:|---:|---:|
| LiPo | < 3,60 V | < 3,40 V | > 4,10 V |
| LiIon | < 3,00 V | < 2,80 V | > 4,10 V |
| LiHv | < 3,60 V | < 3,40 V | > 4,20 V |

Valeurs par cellule. LiHv accepte une tension de charge de 4,35 V par cellule.
La tension affichée est normalisée d'après RxBt et le nombre de cellules ; ce n'est pas une mesure de la cellule individuelle la plus faible.

Le seuil bas doit durer environ 1,2 s, le critique 1 s. Une annonce par épisode et niveau évite les boucles. Une récupération stable de 5 s est nécessaire pour réarmer : seuil bas + 0,08 V, ou seuil critique + 0,08 V. Une perte de télémétrie ne compte pas comme une recharge.

## Alertes et timers

- Alt : strictement au-dessus de 120 m **selon le capteur Alt**, moteurs armés, une annonce par armement. Ce n'est pas le gain depuis le décollage.
- Throttle : 95 % ou plus pendant trois secondes, moteurs armés.
- LQ : sous 70 % pendant deux secondes, moteurs armés.
- Satellite : passage à GPS OK, avec coordonnées valides et au moins cinq satellites.
- TIMER 1 fournit Fly Time et se remet à zéro au désarmement ; TIMER 2 fournit Fly Total sans être réinitialisé.
- Les annonces de modes et de switches suivent leurs changements d'état.

Ne configurez pas les mêmes annonces en double dans EdgeTX.

## GPS et distances

Satellites : 0/absent = NO_DATA ; 1–4 rouge ; 5–7 orange ; 8 et plus vert, selon la palette du skin.
GPS, Sats et GSpd sont acquis environ une fois par seconde ; Alt et RSSI à chaque cycle du widget.

Le premier point GPS utilisable du vrai vol devient le Home. Le vrai vol commence avec ARM et throttle > 5 %. Le trajet total combine vitesse au sol et positions, avec rejet de sauts GPS aberrants : il reste une estimation. Un contrôle moteur à 5 % ou moins préserve les résultats sauvegardés.

## Qwad Finder

Actif avec Beeper, Flip ou RTH, libéré lorsque ces fonctions sont inactives. RSSI prioritaire, repli sur LQ si nécessaire. Sans signal valable, pas de faux bip de proximité.

**Les autres voix JWAIO, y compris batterie critique, attendent pendant la recherche.** Un son déjà lancé finit sa lecture. Les sons d'autres fonctions EdgeTX restent indépendants.

Une force de signal plus élevée rapproche les bips, sans fournir une mesure réelle de distance. La puissance dynamique et les obstacles peuvent tromper l'estimation.

## Skins

Le [guide des skins](SKINS.md) couvre création, ajout, sélection et retrait. Les skins modifient les images et couleurs, pas les seuils ni les commandes.

## Journaux et diagnostic

Dans `/LOGS/JWAIO/`, un `F*.csv` est ouvert à chaque armement. L'écriture est d'environ 1 Hz, avec une ligne finale au désarmement. Les douze colonnes historiques sont complétées par états, tensions, validités, RSSI et Finder.

- `cell_min_v / cell_max_v` : extrêmes observés entre deux lignes, utiles pour le sag ;
- `pack_estimated` : 1 si la tension pack est calculée depuis une valeur par cellule ;
- `samples` : cycles d'acquisition du widget, pas nombre de paquets radio ;
- `nav_age_s` : âge de la lecture navigation par le widget.

Les `E*.csv` enregistrent changements d'état et événements audio, y compris pendant une recherche au sol. `submitted` signifie appel accepté par le lecteur audio, pas preuve qu'un son a été entendu. Les écritures sont groupées ; une coupure peut perdre le dernier lot d'environ une seconde. Un tampon borné limite la mémoire.

`diagnosticsEnabled = false` dans config.lua désactive les journaux E.
`lastpos.txt` et `lastdistance.txt` conservent les dernières informations utiles.

Pour l'import, consultez [Open Drone Log](OPEN_DRONE_LOG.md). Les fichiers bruts contiennent des coordonnées personnelles : ne les publiez pas sans vérification.
