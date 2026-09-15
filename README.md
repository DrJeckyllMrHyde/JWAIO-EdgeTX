# JWAIO v0.3.1

**Jeckyll Widget All in One** rassemble les informations FPV, les alertes vocales et une aide à la recherche du quad sur l'écran de votre radio RadioMaster. Trois archives distinctes sont proposées pour **TX15/TX15 Max**, **TX16S Mk1/Mk2** et **TX16S Mk3**, avec EdgeTX 2.12.x.

> **JWAIO Cleaner — Windows 10/11 :** outil portable de désinstallation avec conservation optionnelle des skins et logs. [Présentation et état du projet](docs/CLEANER.md) · [Rapports antivirus](docs/CLEANER-ANTIVIRUS.md). **EXE non publié : release en brouillon pendant l'examen de 5 alertes VirusTotal (Jotti : 0/13).**

## Choisir et télécharger sa version

| Votre radio | Archive v0.3.1 | État des essais |
|---|---|---|
| TX15 / TX15 Max | [Télécharger TX15](releases/v0.3.1/JWAIO_v0.3.1_TX15_EdgeTx%202.12.x.zip?raw=true) | Testée, fonctionnelle pour tous les usages selon le créateur |
| TX16S Mk1 / Mk2 | [Télécharger Mk1/Mk2](releases/v0.3.1/JWAIO_v0.3.1_TX16MK1_MK2_EdgeTx%202.12.x.zip?raw=true) | Testée, fonctionnelle pour tous les usages selon le créateur |
| TX16S Mk3 | [Télécharger Mk3](releases/v0.3.1/JWAIO_v0.3.1_TX16MK3_EdgeTx%202.12.x.zip?raw=true) | Adaptation disponible ; essais physiques à réaliser |

**TX15 et TX16S Mk1/Mk2 :** les scripts ont été testés et sont fonctionnels pour tous les usages. Seuls des correctifs mineurs et des optimisations restent possibles.

**TX16S Mk3 :** Je ne possède pas cette radio. Le widget a été adapté à partir des spécifications matérielles publiées par RadioMaster et **n'a pas été testé physiquement**. Il nécessite **EdgeTX 2.12.0 ou supérieur** ; le fonctionnement du widget sur le firmware exact installé reste à confirmer. **Des testeurs TX16S Mk3 sont recherchés** : [procédure et informations à transmettre](docs/TESTS_TX16_MK3.md).

Les fichiers conservent leur nom et leur contenu d'origine, ainsi que l'identifiant interne « Preview ». La notice incluse dans le ZIP Mk3 mentionne encore EdgeTX 3.0.0 : consultez la [note de compatibilité](docs/COMPATIBILITE.md) avant installation. La prise en charge de la radio par EdgeTX ne constitue pas un essai physique du widget.

[Guide débutant](docs/INSTALLATION.md) · [Mode d'emploi](docs/MODE_EMPLOI.md) · [Version texte](MODE_EMPLOI.txt) · [Notes de version](CHANGELOG.md)

## Installer en quelques étapes

1. Téléchargez **uniquement l'archive de votre radio** dans le tableau ci-dessus. Le ZIP général « Code / Download ZIP » du dépôt n'est pas un paquet d'installation.
2. Sauvegardez le stockage de la radio et votre modèle EdgeTX, y compris vos réglages JWAIO, skins et journaux.
3. Décompressez l'archive sur l'ordinateur. **Pour Mk1/Mk2, ouvrez d'abord le dossier `JWAIO-v0.3.1_TX16S-Mk1-Mk2`.**
4. Branchez le port USB de données de la radio, choisissez **USB Storage / Stockage USB**, puis ouvrez le volume utilisé par EdgeTX pour ses scripts.
5. Copiez les dossiers **WIDGETS, SOUNDS, SCRIPTS et LOGS** à la racine de ce volume. Fusionnez les dossiers et remplacez uniquement les fichiers JWAIO concernés.
6. Éjectez proprement le volume et redémarrez la radio. Découvrez les capteurs du modèle, ajoutez JWAIO dans une zone unique et vérifiez les dix options.
7. Effectuez les premiers contrôles au sol, hélices retirées. Le [guide illustré par des chemins concrets](docs/INSTALLATION.md) détaille chaque étape et le dépannage.
8. NOTE : Pour la version TX16 -> Une fois le widget sur votre écran d'accueil, il faudra le mettre manuellement en plein écran pour bénéficié de l'affichage.

Le chemin final doit être `/WIDGETS/JWAIO/main.lua`, sans dossier d'archive intermédiaire. Une seule variante et une seule instance JWAIO par modèle : toutes utilisent les mêmes chemins.

## Ce que propose le widget

- États Ready / Pre-Arm / Arm, affichage des modes ANGLE / ACRO / RTH et des gaz.
- Batterie LiPo, LiIon ou LiHv, de 1 à 8 cellules, avec alertes vocales filtrées.
- Qualité de liaison LQ, RSSI, GPS du véhicule, satellites, altitude et vitesse au sol.
- Temps de vol avec TIMER 1 et cumul avec TIMER 2, à configurer dans EdgeTX.
- Dernière position, distance maximale et trajet estimé ; journaux CSV de vol et d'événements.
- **Qwad Finder** : jauge et bips guidés par la force du signal.
- Skin JWAIO fourni, fonds/logos/couleurs personnalisables et effets lumineux optionnels selon la radio.

JWAIO affiche les commandes déjà configurées dans votre modèle : il ne configure ni l'armement, ni le retour GPS, ni le contrôleur de vol. Les états affichés ne sont pas une confirmation envoyée par le drone.

## Les dix options à vérifier

| Option | Ce que vous choisissez |
|---|---|
| Skin | Apparence ; JWAIO est fourni |
| BatType | Type batterie de la machine : LiPo, LiIon ou LiHv |
| Cells | Nombre réel de cellules, de 1 à 8 ; défaut 6 |
| LinkType | ELRS ou TBS_CF ; les noms de capteurs ne sont pas remappés automatiquement |
| ARM | Position de l'interrupteur qui arme déjà votre modèle |
| PreArm | Position de pré-armement, si utilisée |
| Beeper | Position qui active déjà le beeper |
| Flip | Position du retournement après crash |
| RTH | Position de retour GPS, si configuré |
| Thr | Voie des gaz ; CH3 par défaut, à vérifier |

Les capteurs attendus sont **RxBt, RQly, 1RSS, GPS, Alt, GSpd et Sats**. Leurs noms sont ajustables dans `/WIDGETS/JWAIO/config.lua`. Sans GPS, batterie et liaison restent utilisables si leurs capteurs sont disponibles. Une donnée indisponible s'affiche `NO_DATA`.

## Recherche du quad et journaux

Le Finder s'active avec Beeper, Flip ou RTH ; il s'arrête quand ces trois commandes sont inactives. Le RSSI est prioritaire, avec repli sur LQ. **Pendant la recherche, les autres alertes vocales JWAIO, y compris batterie critique, sont différées ou supprimées selon leur état ; les confirmations Beeper/Flip/RTH restent autorisées.** Un son déjà lancé se termine. Les alertes configurées ailleurs dans EdgeTX sont indépendantes.

La jauge indique une force de signal, pas une distance ni une direction garantie. Les obstacles et la puissance dynamique influencent le résultat.

Les fichiers `F*.csv`, `E*.csv`, `lastpos.txt` et `lastdistance.txt` sont enregistrés dans `/LOGS/JWAIO/`. Les distances démarrent pour un nouveau vol lorsque ARM est actif et les gaz dépassent 5 %. Pour importer les CSV dans Open Drone Log, utilisez le [convertisseur et son guide](docs/OPEN_DRONE_LOG.md). Vérifiez les coordonnées contenues dans les journaux avant de les partager.

## Documentation, archives et licences

- [Installation, mise à jour, dépannage et désinstallation](docs/INSTALLATION.md)
- [Utilisation, alertes, capteurs et minuteries](docs/MODE_EMPLOI.md)
- [Compatibilité et état des essais](docs/COMPATIBILITE.md)
- [Appel aux testeurs Mk3](docs/TESTS_TX16_MK3.md)
- [Personnaliser les skins](docs/SKINS.md)
- [Archives originales v0.3.1 et empreintes SHA-256](releases/v0.3.1/README.md)

Le dossier `sdcard/`, les outils de construction et les tests historiques concernent encore la base 0.3.0-alpha. **Pour installer v0.3.1, utilisez les trois archives ci-dessus.** L'ancienne archive et la release alpha restent disponibles pour l'historique.

Code : [Apache 2.0](LICENSE). Documents et médias concernés : [licence des ressources](LICENSE-ASSETS.md). [Auteurs](AUTHORS.md), [NOTICE](NOTICE), [composants tiers](sdcard/THIRD_PARTY_NOTICES.txt).

© 2026 **DrJeckyllMrHyde** — [YouTube JeckyllHydeFpv](https://www.youtube.com/@JeckyllHydeFpv)
