# Galerie de skins JWAIO

JWAIO est installé avec son skin de base. Cette galerie vous permet de découvrir d'autres styles et de télécharger uniquement celui que vous souhaitez utiliser. Votre radio reste ainsi propre, sans collection de skins inutilisés.

Pour chaque skin, je propose un aperçu et un tableau de téléchargement par radio. Choisissez toujours la ligne qui correspond exactement à votre modèle.

## Skin JWAIO — base

<p align="center">
  <img src="../docs/assets/JWAIO-0.3.1-Widget-Facebook-v3.png" alt="Aperçu du skin JWAIO de base" width="760">
</p>

Le skin JWAIO est fourni avec le widget. Les paquets ci-dessous permettent de le restaurer ou de l'utiliser comme base pour créer un nouveau skin.

La version TX15 est différente des versions TX16S : la TX15 possède des LED pilotables que les TX16S ne possèdent pas. Son skin contient donc des fichiers et des effets LED spécifiques. Il est important de télécharger le paquet correspondant exactement à votre radio, même si l'apparence affichée à l'écran reste proche.

| Radio | Particularité du skin | Télécharger |
|---|---|---|
| TX15 / TX15 Max | Gestion et effets LED propres à la TX15 | [Skin JWAIO pour TX15](jwaio/JWAIO-Skin-JWAIO-TX15.zip?raw=true) |
| TX16S Mk1 / Mk2 | Version sans les effets LED de la TX15 | [Skin JWAIO pour TX16S Mk1/Mk2](jwaio/JWAIO-Skin-JWAIO-TX16S-Mk1-Mk2.zip?raw=true) |
| TX16S Mk3 | Version sans les effets LED de la TX15 ; essai physique recherché | [Skin JWAIO pour TX16S Mk3](jwaio/JWAIO-Skin-JWAIO-TX16S-Mk3.zip?raw=true) |

[Vérifier les empreintes SHA-256](jwaio/SHA256SUMS.txt)

### Installation

1. Sauvegardez le stockage de votre radio.
2. Téléchargez le ZIP correspondant à votre modèle, puis décompressez-le.
3. Copiez le dossier `jwaio` obtenu dans `/WIDGETS/JWAIO/skins/`.
4. Acceptez le remplacement uniquement si vous souhaitez restaurer le skin de base déjà présent.
5. Éjectez proprement la radio et redémarrez-la.

Pour installer un futur skin sans remplacer le skin de base, son ZIP contiendra un dossier portant un autre nom. Il suffira de le copier à côté du dossier `jwaio`, puis de le sélectionner dans l'option **Skin** du widget.

Vous souhaitez créer votre propre style ? Consultez le [guide de création et de personnalisation](../docs/SKINS.md).

## D-Sync Crew — Freestyle Underground

<p align="center">
  <img src="dsync-underground/JWAIO-0.3.1-D-Sync-Crew-Freestyle-Underground.jpg" alt="Aperçu du skin D-Sync Crew Freestyle Underground" width="760">
</p>

**Votre Freestyle, Votre style !**

Un univers sombre inspiré des bandos et du freestyle FPV, avec un décor noir, des textures carbone et des touches de cyan électrique. Cette première version intègre les effets LED propres à la TX15.

| Radio | Disponibilité | Télécharger |
|---|---|---|
| TX15 / TX15 Max | Disponible avec effets LED spécifiques | [Télécharger le skin](dsync-underground/JWAIO-v0.3.1-skin-dsync-underground-TX15.zip?raw=true) |
| TX16S Mk1 / Mk2 | Pas encore disponible | — |
| TX16S Mk3 | Pas encore disponible | — |

[Vérifier l'empreinte SHA-256](dsync-underground/SHA256SUMS.txt)

Après avoir décompressé le ZIP, copiez le dossier `dsync-underground` dans `/WIDGETS/JWAIO/skins/`, à côté du dossier `jwaio`. Redémarrez ensuite la radio et choisissez **DSYNC** dans l'option **Skin** du widget.

## Modèle pour les prochains skins

Chaque nouveau skin ajouté à cette galerie reprendra la même présentation : un aperçu, une courte description et un tableau proposant le bon paquet pour chaque radio compatible. Vous pourrez ainsi comparer les styles avant de télécharger quoi que ce soit.