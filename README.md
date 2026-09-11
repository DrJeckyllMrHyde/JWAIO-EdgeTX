# JWAIO 0.3.1_Preview

**Jeckyll Widget All in One** — widget Lua FPV plein écran pour **RadioMaster TX15 - TX15 Max - TX16 Mk1 à Mk3 / EdgeTX 2.12.x**.


Vos informations avant décollage, vos alertes en vol et votre aide à la recherche du quad, réunies sur la radio. Cette version alpha reprend le correctif de télémétrie validé sur la radio du créateur ; les retours de la communauté restent essentiels.

## Télécharger et installer

[⬇️ **Télécharger JWAIO 0.3_Alpha**](https://github.com/DrJeckyllMrHyde/JWAIO-EdgeTX/releases/download/v0.3-alpha/JWAIO-v0.3.0-alpha.zip)

Le bouton télécharge directement le ZIP d'installation. GitHub remplace l'espace
du nom par un point : **JWAIO.0.3_Alpha.zip**. Ne choisissez pas « Source code ».

1. Sauvegardez le stockage et le modèle de votre radio, ainsi que vos logos et journaux.
2. Radio allumée, branchez le port USB de données et choisissez **USB Storage**.
3. Copiez le contenu du ZIP **à la racine du stockage EdgeTX utilisé par la radio**. Fusionnez les dossiers, remplacez les fichiers JWAIO, sans formater ni supprimer les autres dossiers.
4. Éjectez proprement le lecteur, puis redémarrez la radio.
5. Hélices retirées, découvrez les capteurs du modèle, puis ajoutez JWAIO dans une zone plein écran et vérifiez ses réglages.

Les dossiers `WIDGETS/JWAIO`, `SOUNDS/fr/JWAIO` et `LOGS/JWAIO` doivent se trouver directement à la racine, sans dossier intermédiaire.

**Mise à jour :** si votre ancien menu n'avait pas l'option Skin, retirez l'instance de la page puis ajoutez-la à nouveau. Vérifiez tous les switches : l'ordre des options a changé. Depuis une alpha avec Skin, conservez l'instance et ses réglages.

[Mode d'emploi simple](MODE_EMPLOI.txt) · [Installation et désinstallation](docs/INSTALLATION.md) · [Créer son skin](docs/SKINS.md)

> JWAIO ne commande pas le drone : les options de switches indiquent au widget les fonctions déjà configurées dans votre modèle. Il ne remplace ni l'OSD, ni les contrôles de sécurité, ni une balise autonome.

## Ce que propose JWAIO

- États **Ready / Pre-Arm / Arm**, modes **ANGLE / ACRO / RTH**.
- Throttle en pourcentage, cinq jauges PNG et alerte à partir de trois secondes à 95 % ou plus.
- **Fly Time = TIMER 1**, remis à zéro au désarmement ; **Fly Total = TIMER 2**, non remis à zéro par JWAIO.
- Batteries **LiPo, LiIon, LiHv**, de 1 à 8 cellules, avec annonces pleine/faible/critique et filtrage des creux brefs de tension.
- Liaison **ELRS ou TBS_CF** : LQ et RSSI, plus alerte de qualité de liaison.
- GPS, satellites, dernière position, vitesse au sol, altitude et distances estimées.
- **Qwad Finder** : jauge de signal et bips rapprochés quand le signal devient plus fort.
- **Skins** sélectionnables dans le menu : fond, logo et couleurs personnalisables, sans toucher aux fonctions.
- CSV de vol enrichis et journal d'événements pour analyser les essais.

### Correctif de télémétrie

Une mesure encore valide reste affichée entre deux réceptions : l'absence de nouvelle valeur « fraîche » n'est plus confondue avec un capteur perdu. Une véritable perte signalée par EdgeTX reste affichée `NO_DATA`. Les données absentes ne sont pas transformées en faux zéros.

### Qwad Finder : fonctionnement et limites

Il s'active avec **Beeper, Flip ou RTH**, et se libère lorsque les trois sont inactifs. Le RSSI est utilisé en priorité, avec repli sur LQ. Les bips visent une période de **1,2 s à 0,20 s**, selon le signal et le rythme d'appel d'EdgeTX.

**Pendant la recherche, les autres annonces JWAIO, y compris batterie critique, sont différées.** Un son déjà commencé se termine. Les sons configurés ailleurs dans EdgeTX ne sont pas contrôlés par JWAIO.

La jauge ne donne ni une distance en mètres ni une direction garantie : les obstacles, l'orientation des antennes et la puissance dynamique influencent le signal.

## Les dix réglages

| Option | Fonction |
|---|---|
| Skin | Identité visuelle installée ; JWAIO fourni |
| BatType | LiPo par défaut, LiIon ou LiHv |
| Cells | 1 à 8, valeur initiale 6 |
| LinkType | ELRS par défaut ou TBS_CF |
| ARM | Position du switch d'armement |
| PreArm | Position du switch de pré-armement |
| Beeper | Position d'activation du beeper |
| Flip | Position d'activation du flip après crash |
| RTH | Position d'activation du retour |
| Thr | Voie des gaz, CH3 par défaut |

**RQly est lu directement**, sans option LQ supplémentaire. Les noms de capteurs se règlent au besoin dans `/WIDGETS/JWAIO/config.lua`.

| Donnée | Capteur attendu |
|---|---|
| Batterie | RxBt |
| Qualité de liaison | RQly |
| RSSI | 1RSS |
| Position | GPS |
| Altitude | Alt |
| Vitesse au sol | GSpd |
| Satellites | Sats |

Sans GPS en freestyle, batterie et liaison restent utilisables. Altitude et vitesse sont affichées si leurs propres capteurs sont valides ; aucune trajectoire ni distance n'est inventée.

## Système de skins

Le paquet contient le skin **JWAIO**. Chaque skin est un dossier dans `/WIDGETS/JWAIO/skins/` comprenant :

- `background.png` : **480 × 320 px**, PNG RGB opaque recommandé ;
- `logo.png` : **216 × 132 px**, PNG RGBA avec transparence ;
- `skin.lua` : identité, numéro d'emplacement et palette.

Les skins sont découverts au chargement. Après ajout d'un dossier, redémarrez EdgeTX puis choisissez **Skin** dans les options. Le changement entre skins déjà découverts ne nécessite pas de remplacer les fichiers.

➡️ [Guide complet : créer, installer et dépanner un skin](docs/SKINS.md).

N'installez que des skins de confiance : `skin.lua` est un fichier Lua exécuté par la radio. Respectez les droits des images utilisées.

## Journaux de vol et Open Drone Log

Dans `/LOGS/JWAIO/` :

- `F*.csv` : un fichier par armement, environ une ligne par seconde et une dernière ligne au désarmement ;
- `E*.csv` : états et événements audio, y compris la recherche au sol ;
- `lastpos.txt` : dernière latitude/longitude exploitable ;
- `lastdistance.txt` : distance maximale et trajet total sauvegardés.

Les distances repartent pour un nouveau vol uniquement lorsque **ARM est actif et le throttle dépasse 5 %**. Un contrôle moteur à faible gaz ne réinitialise pas les résultats du dernier vrai vol.

Les CSV s'ouvrent dans Excel ou LibreOffice. Pour Open Drone Log, utilisez le [convertisseur et son guide](docs/OPEN_DRONE_LOG.md) : le fichier brut n'est pas son format d'import standard. Les diagnostics restent dans le fichier original ; sans GPS, aucune carte de trajet ne peut être reconstruite.

Les fichiers contiennent des positions : vérifiez-les avant tout partage public.

## Tester et signaler un problème

Effectuez les premiers contrôles **au sol, hélices retirées**. Vérifiez les valeurs, les switches, la perte/reprise de télémétrie et les sons avant le vol. Évitez de configurer une deuxième fois les mêmes alertes dans EdgeTX.

Pour un retour utile : modèle de radio, version EdgeTX, type de batterie, nombre de cellules, skin, description du problème, puis CSV F et E correspondants. Ne publiez pas vos coordonnées personnelles dans une issue.

## Documentation et licences

- [Mode d'emploi](docs/MODE_EMPLOI.md)
- [Créer un skin](docs/SKINS.md)
- [Notes de version](CHANGELOG.md)
- Code : [Apache 2.0](LICENSE) ; documents et médias concernés : [CC BY 4.0](LICENSE-ASSETS.md).
- [Auteurs](AUTHORS.md), [NOTICE](NOTICE) et [composants tiers](sdcard/THIRD_PARTY_NOTICES.txt).

© 2026 **DrJeckyllMrHyde** — [YouTube JeckyllHydeFpv](https://www.youtube.com/@JeckyllHydeFpv)
