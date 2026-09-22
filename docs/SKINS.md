# Personnaliser JWAIO avec les skins

Un skin change le fond, le logo et les couleurs. Il ne modifie ni les capteurs,
ni les alertes, ni le fonctionnement du widget. Le skin officiel **JWAIO** est inclus.

## Affichage selon la radio en v0.3.1

Les trois ZIP fournissent le même fond 480 × 320 et le même logo 216 × 132. Le code adapte leur affichage à la radio : TX15 480 × 320, Mk1/Mk2 480 × 272 (fond centré et recadré), Mk3 800 × 480 (mise à l'échelle). Vérifiez donc la lisibilité et le cadrage sur votre radio ; la Mk3 reste sans validation physique. Les effets LED dépendent de l’équipement et du firmware. Ils sont activés par défaut dans le paquet TX15 actualisé ; les paquets TX16S gardent leur réglage désactivé.

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

## LED du skin JWAIO sur TX15

Le paquet TX15 actualisé le 22 septembre 2026 **active les LED par défaut** dans le skin JWAIO. Les paquets TX16S restent inchangés, avec leurs LED désactivées par défaut. Le module nécessite les fonctions RGBLED du firmware ; s’il ne les trouve pas, il reste inactif.

Les fichiers se trouvent dans `/WIDGETS/JWAIO/skins/jwaio/leds/` : `config.lua` contient les réglages et `effects.lua` les animations. Copiez le paquet TX15 complet pour disposer aussi des modules qui lisent les manches et pilotent les LED.

1. Désactivez les autres scripts RGBLED de la radio pour éviter qu’ils pilotent les mêmes LED.
2. Installez le paquet TX15, sélectionnez le skin JWAIO et redémarrez la radio.
3. Le réglage fourni utilise `enabled = 1`, `count = 20`, `brightness = 30` et `fps = 10`. La luminosité est un pourcentage de commande, pas une mesure de consommation.
4. Pour couper les effets, ouvrez `leds/config.lua` sur l’ordinateur, passez `local enabled = 1` à `local enabled = 0`, enregistrez puis redémarrez. Ne modifiez pas ce fichier pendant que le widget fonctionne.
5. Vérifiez les anneaux et leurs réactions au sol. Les commandes du modèle et les alertes vocales gardent leur rôle habituel.

| État | Effet fourni |
|---|---|
| Batterie faible ou critique | Clignotement rouge prioritaire, selon le type de batterie configuré |
| RTH | Pulsation rouge |
| Beeper / Flip (Finder) | Pulsation verte, accélérée lorsque le signal augmente |
| Armé | Halos bleus suivant les manches ; disposition prévue pour les modes 1 et 2 |
| Acquisition GPS, niveau satellite 3 | Trois impulsions vertes sur 1,5 seconde, si aucun état prioritaire ne masque l’effet |
| Pré-armement | Pulsation dorée |
| Ready | Respiration blanc chaud |

Priorité : batterie → RTH → Finder/Flip → armement → GPS → pré-armement → Ready. L’animation armée utilise actuellement le bleu également en ANGLE : la couleur `angle` présente dans la configuration n’est pas utilisée par l’effet fourni. Un Finder sans signal valide conserve une pulsation verte lente ; elle ne confirme pas une liaison valide.

Les LED signalent les valeurs et commandes connues du widget ; elles ne constituent pas une confirmation d’armement ou de RTH transmise par le drone. Cette mise en ligne et ses simulations sur ordinateur n’ajoutent pas de validation physique des effets.

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
communs au widget dans `/SOUNDS/fr/JWAIO/` : cette version ne choisit pas un pack
audio différent selon le skin.
