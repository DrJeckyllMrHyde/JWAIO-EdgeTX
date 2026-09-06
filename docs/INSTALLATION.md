# Installer ou supprimer JWAIO 0.3_Alpha

## Installation

1. Sauvegardez le contenu du stockage de la radio, le modèle EdgeTX, vos images et vos journaux.
2. Téléchargez le ZIP d'installation depuis la [release](https://github.com/DrJeckyllMrHyde/JWAIO-EdgeTX/releases/tag/v0.3-alpha).
3. Radio allumée, branchez le port USB de données et choisissez **USB Storage**.
4. Copiez le contenu de l'archive à la racine du stockage EdgeTX utilisé par la radio : mémoire interne ou microSD selon votre configuration.
5. Acceptez la fusion et le remplacement des fichiers JWAIO, sans formater ni supprimer les autres dossiers.
6. Éjectez proprement le lecteur et redémarrez EdgeTX.
7. Hélices retirées, découvrez les capteurs, ajoutez JWAIO dans une zone plein écran et vérifiez ses options.

Si l'ancien menu ne proposait pas Skin, retirez l'instance de la page et ajoutez-la à nouveau. Sinon, conservez vos réglages. Vérifiez toujours les affectations ARM, PreArm, Beeper, Flip et RTH après une mise à jour.

Chemins attendus à la racine :

```text
/WIDGETS/JWAIO/
/SOUNDS/fr/JWAIO/
/LOGS/JWAIO/
```

Ne copiez pas le dossier englobant le ZIP : `WIDGETS` doit être directement à la racine.

## 3b. Supprimer le widget

1. Sauvegardez les CSV et vos skins.
2. Sur la radio, retirez JWAIO de toutes les pages et de tous les modèles concernés.
3. Branchez la radio en **USB Storage**.
4. Supprimez uniquement `/WIDGETS/JWAIO/` et `/SOUNDS/fr/JWAIO/`.
5. Gardez `/LOGS/JWAIO/` pour conserver les vols, dernières coordonnées et distances. Ne le supprimez que si vous acceptez de perdre ces données.
6. Retirez éventuellement `/JWAIO_README.txt`.
7. Éjectez proprement puis redémarrez la radio.

**Ne supprimez jamais les dossiers parents `/WIDGETS/`, `/SOUNDS/` ou `/LOGS/`.** Ils peuvent contenir les données d'autres widgets.

## Vérification au sol

- Les valeurs restent visibles entre deux réceptions.
- Les vrais capteurs perdus passent à NO_DATA après le délai géré par EdgeTX.
- Après reconnexion du drone, les valeurs reviennent sans recharger JWAIO.
- Les switches affichés et les gaz correspondent au modèle.
- Les sons ne sont pas doublés par d'autres alertes EdgeTX.

Voir le [mode d'emploi](MODE_EMPLOI.md) et le [guide des skins](SKINS.md).
