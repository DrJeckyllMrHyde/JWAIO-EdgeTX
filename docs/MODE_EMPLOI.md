# Utiliser JWAIO v0.3.1 Alpha

Je vous conseille de commencer par l'installation et les réglages au sol. Pour la première installation, suivez le [guide débutant](INSTALLATION.md). Les [statuts par radio](COMPATIBILITE.md) distinguent TX15/Mk1/Mk2 testés et Mk3 sans essai physique.

## Régler les dix options

Ouvrez les options de l'instance JWAIO dans la configuration de l'écran EdgeTX.

| Option | Réglage conseillé pour commencer |
|---|---|
| Skin | JWAIO, l'apparence fournie |
| BatType | La chimie du pack du véhicule : LiPo, LiIon ou LiHv |
| Cells | Son nombre réel de cellules ; 6 par défaut, de 1 à 8 |
| LinkType | ELRS ou TBS_CF selon votre liaison |
| ARM | La position d'interrupteur qui arme déjà votre modèle |
| PreArm | La position de pré-armement si votre modèle en utilise une |
| Beeper | La position qui active le beeper, sinon désactivée |
| Flip | La position du retournement après crash, sinon désactivée |
| RTH | La position du retour GPS déjà configuré, sinon désactivée |
| Thr | La voie des gaz réelle ; CH3 est proposée par défaut |

ARM recherche SE bas et PreArm SF bas par défaut : vérifiez les affectations réelles, particulièrement sur les panneaux modulaires Mk3. Beeper, Flip et RTH sont initialement désactivés. Les options indiquent au widget les commandes existantes ; elles n'ajoutent aucune fonction au drone.

**Modes :** les trois paquets lisent SA par défaut : SA bas affiche ANGLE, haut/milieu ACRO. RTH est prioritaire. Pour une autre commande, ajustez `modeSource` et `modeAnglePosition` dans `/WIDGETS/JWAIO/config.lua`, puis redémarrez. Ce sont des indications de commande, pas une confirmation du mode réel du contrôleur de vol.

## Capteurs et unités

| Donnée | Nom attendu | À vérifier |
|---|---|---|
| Batterie | RxBt | Tension du véhicule, pas une autre alimentation |
| Qualité de liaison | RQly | LQ disponible et cohérente |
| Puissance reçue | 1RSS | RSSI disponible |
| Position | GPS | GPS du véhicule |
| Altitude | Alt | Valeur en mètres |
| Vitesse au sol | GSpd | Valeur en km/h ; `speedMultiplier = 1.0` par défaut |
| Satellites | Sats | Nombre fourni par la télémétrie |

Découvrez les capteurs dans EdgeTX avant de charger JWAIO. Le choix LinkType change le libellé de liaison, sans adapter automatiquement les noms de capteurs. En cas de noms différents, modifiez les champs `batterySource`, `lqSource`, `rssiSource`, `gpsSource`, `altitudeSource`, `speedSource` et `satellitesSource` de `config.lua` pour correspondre aux capteurs de votre modèle. Redémarrez après modification. Adaptez `speedMultiplier` si la vitesse est fournie dans une autre unité.

Une mesure valide reste affichée entre deux réceptions. Les données absentes ou invalides restent `NO_DATA`. Sans GPS, les mesures batterie et liaison continuent si leurs capteurs sont disponibles ; aucune position n'est inventée.

## Batterie et alertes

| Profil | Seuil bas par cellule | Seuil critique par cellule | Seuil d'annonce pleine |
|---|---:|---:|---:|
| LiPo | 3,60 V | 3,40 V | 4,10 V |
| LiIon | 3,00 V | 2,80 V | 4,10 V |
| LiHv | 3,60 V | 3,40 V | 4,20 V |

Ces valeurs sont les réglages fournis. La tension par cellule est calculée ou normalisée depuis RxBt et Cells ; ce n'est pas une mesure individuelle de la cellule la plus faible. Une brève chute de tension est filtrée : environ 1,2 s pour l'alerte basse, 1 s pour la critique. Une récupération stable permet le réarmement des annonces. Les réglages avancés sont dans `config.lua`.

L'alerte de gaz vise au moins 95 % pendant trois secondes, moteurs armés. L'alerte de liaison utilise un seuil LQ de 70 % et un délai de deux secondes. L'alerte d'altitude utilise Alt au-dessus de 120 m, moteurs armés : il s'agit par défaut de la référence du capteur, pas d'une hauteur automatiquement calculée depuis le décollage.

Évitez de programmer les mêmes annonces deux fois dans EdgeTX et JWAIO.

## Minuteries : Fly Time et Fly Total

**Fly Time utilise TIMER 1.** Dans les paramètres du modèle EdgeTX, configurez un compteur montant à partir de zéro et une condition de marche adaptée à votre modèle, par exemple l'interrupteur d'armement. JWAIO remet ce compteur à zéro au démarrage désarmé puis au désarmement.

**Fly Total utilise TIMER 2.** Configurez sa condition de marche et, si vous souhaitez garder le cumul après extinction, sa persistance dans EdgeTX. JWAIO ne remet pas TIMER 2 à zéro et ne définit pas la condition de marche des compteurs.

## Satellites, GPS et distances

Pour une valeur Sats valide : **0 à 4 rouge**, **5 à 6 orange**, **7 ou plus vert**. Une donnée absente ou périmée reste `NO_DATA`.

Après environ deux secondes d'état stable, les annonces satellites dépendent du contexte : au sol, orange et vert ont leurs annonces ; en vol, rouge et orange signalent les niveaux correspondants. Aucune annonce satellite n'est déclenchée dans l'état armé avec gaz à 5 % ou moins. Ces seuils d'affichage ne prouvent pas que le retour GPS du contrôleur de vol est prêt.

Un nouveau calcul de distances débute quand ARM est actif et les gaz dépassent 5 %. Le premier point GPS exploitable du vrai vol devient le point de départ Home. La distance maximale et le trajet restent des estimations ; les sauts GPS sont filtrés. Un contrôle moteur à 5 % ou moins conserve les résultats du dernier vol.

## Qwad Finder

Activez l'une des commandes Beeper, Flip ou RTH affectées au widget pour lancer la recherche. Mettez les trois commandes sur leur position inactive pour l'arrêter. Le RSSI est utilisé en priorité, puis la LQ si nécessaire. Sans signal valide, le widget ne produit pas de fausse indication de proximité.

Plus le signal est fort, plus les bips sont rapprochés. La cadence visée va d'environ 1,2 s à 0,20 s. Les obstacles, l'orientation des antennes et la puissance dynamique influencent le résultat : ce n'est ni une distance en mètres ni une direction garantie.

**Pendant le Finder, les autres annonces JWAIO, y compris batterie critique, sont différées ou supprimées selon leur état.** Les confirmations Beeper/Flip/RTH restent autorisées. Un son commencé se termine. Les annonces extérieures à JWAIO ne sont pas contrôlées par le widget ; ne comptez pas sur la lecture ultérieure systématique d'une alerte passée.

## Apparence et effets lumineux

Le skin JWAIO est fourni dans les trois variantes. Pour ajouter une apparence, consultez le [guide des skins](SKINS.md). Les images livrées sont communes ; leur placement et leur adaptation dépendent de la radio.

Les effets lumineux sont optionnels. Ils sont activés par défaut sur TX15 et restent désactivés dans les paquets TX16S. Sur Mk3, leur adaptation vise les 20 LED des anneaux lorsqu'ils sont présents, sans les six LED de boutons ; leur fonctionnement réel reste à tester. Conservez le réglage désactivé pour une première installation Mk3.

## Journaux et aide au diagnostic

Dans `/LOGS/JWAIO/`, `F*.csv` enregistre les vols à partir de l'armement, environ une ligne par seconde et une dernière ligne au désarmement. `E*.csv` enregistre les états et événements audio. `lastpos.txt` conserve une dernière position exploitable ; `lastdistance.txt` les dernières distances.

Dans les diagnostics, `submitted` signifie qu'un appel audio a été accepté, pas qu'un son a été entendu. Une coupure peut perdre le dernier lot d'écritures. `diagnosticsEnabled = false` dans `config.lua` désactive les journaux d'événements E.

Les CSV s'ouvrent dans un tableur. Le [convertisseur Open Drone Log](OPEN_DRONE_LOG.md) adapte les journaux au format d'import ; gardez le fichier original pour les diagnostics. Avant partage, retirez les coordonnées que vous souhaitez garder privées.

Pour signaler un problème dans les [Issues](https://github.com/DrJeckyllMrHyde/JWAIO-EdgeTX/issues), indiquez la radio exacte, la version complète d'EdgeTX, le paquet utilisé, les options, les capteurs concernés, le résultat attendu et observé. Les retours Mk3 peuvent suivre la [fiche dédiée](TESTS_TX16_MK3.md).

## LED du skin TX15

Le paquet TX15 active les LED du skin JWAIO par défaut. Désactivez les autres scripts RGBLED et consultez le [guide des effets et réglages](SKINS.md#led-du-skin-jwaio-sur-tx15). Les paquets TX16S gardent leur réglage désactivé.
