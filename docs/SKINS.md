# Personnaliser JWAIO avec les skins

Un skin change le fond, le logo et les couleurs. Il ne modifie ni les capteurs,
ni les alertes, ni le fonctionnement du widget. Le skin officiel **JWAIO** est inclus.

## Installer et choisir un skin

1. Sauvegardez la mémoire de stockage utilisée par la radio.
2. Copiez le dossier du skin dans `/WIDGETS/JWAIO/skins/`, à côté de `jwaio`.
3. Éjectez proprement le lecteur et redémarrez la radio.
4. Dans les réglages du widget JWAIO, choisissez **Skin**, la première option.

Les dossiers sont recherchés au démarrage. Il ne faut pas remplacer le dossier
`jwaio` : il sert de secours. Si le menu affiche encore LQ au lieu de Skin,
retirez le widget de son emplacement, ajoutez-le à nouveau et vérifiez toutes
ses options, surtout les switches.

## Créer son premier skin

Dupliquez le dossier `jwaio` et nommez la copie `monskin`.
Utilisez un nom court sans espace ni accent (lettres, chiffres, tiret ou souligné).

```text
/WIDGETS/JWAIO/skins/monskin/
    skin.lua
    background.png
    logo.png
```

- **background.png** : PNG de **480 × 320 pixels**, sombre et sans animation.
- **logo.png** : PNG de **216 × 132 pixels**, de préférence avec transparence.
  Le logo du widget est personnel : celui de la documentation n'est pas imposé.
- **skin.lua** : petit fichier texte décrivant les images et les couleurs.

Gardez les noms de fichiers et leur casse identiques à ceux du manifeste.
Ne copiez pas un dossier supplémentaire autour de `monskin`.

## Exemple de skin.lua

Remplacez le contenu du fichier de votre copie par :

```lua
-- Mon skin JWAIO : couleurs RVB de 0 a 255.
return {
  api = 1,
  id = "monskin",
  name = "MonSkin",
  slot = 2,
  background = "background.png",
  logo = "logo.png",
  panelsBaked = false,
  palette = {
    black = {0, 0, 0},
    panel = {9, 11, 14},
    line = {45, 116, 210},
    white = {244, 246, 248},
    grey = {135, 143, 153},
    orange = {255, 132, 28},
    green = {126, 190, 38},
    red = {255, 55, 55},
    blue = {75, 142, 255}
  }
}
```

**name** est le nom dans le menu (10 caractères ASCII maximum conseillé).
**id** est un identifiant court sans espace. **slot** est la place dans le menu :
1 est réservé à JWAIO ; utilisez une place libre de 2 à 8. Deux skins ne doivent
pas partager le même slot, sinon un seul sera retenu. Gardez ce numéro stable
après installation pour conserver le choix enregistré par la radio.

Les entrées non utilisées entre deux slots peuvent apparaître comme `N/A`.
Une sélection absente se replie sur JWAIO. Le système comporte au maximum huit
emplacements de skin, sans ajouter d'option au menu du widget.

## Lisibilité et performances

Gardez **panelsBaked = false** : le widget dessine lui-même des panneaux sombres
derrière les modules. Leur couleur vient de **panel** ; il s'agit d'aplats,
pas d'un réglage d'opacité. Le fond et les images sont statiques.

La variante **panelsBaked = true** est réservée à un fond qui contient déjà tous
les panneaux aux emplacements du widget ; elle n'est pas nécessaire pour un
premier skin. Ne changez pas les positions des informations dans le code.

Conservez une différence nette entre les états normal, avertissement et critique.
Testez le résultat sur la radio, avec et sans télémétrie : un joli fond sur PC
peut masquer les petites valeurs sur l'écran.

## Si le skin ne fonctionne pas

- Vérifiez le chemin, les dimensions des PNG et les noms exacts.
- Vérifiez les virgules, guillemets et accolades de `skin.lua`.
- Vérifiez `api = 1`, un slot libre entre 2 et 8 et les trois composantes RVB.
- Redémarrez la radio après avoir ajouté un dossier.
- `SKIN ERROR` signale une image non chargée : revenez au skin JWAIO.

Un manifeste invalide est ignoré. **Un skin contient du Lua exécuté par la radio :
n'installez que des fichiers provenant d'une source de confiance.** Le chargement
protégé contre les erreurs n'est pas une protection contre du code malveillant.

Ne partagez que les visuels et sons dont vous détenez les droits. Les sons restent
communs au widget dans `/SOUNDS/fr/JWAIO/` : cette alpha ne choisit pas un pack
audio différent selon le skin.

