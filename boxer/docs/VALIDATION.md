# Compatibilité et validation

## Cible

| Élément | État |
|---|---|
| RadioMaster Boxer | Démarrage, stabilité hors USB et sons validés par Charly |
| Écran monochrome 128 × 64 | Interface dédiée |
| EdgeTX | 2.12.2 |
| Script TOOLS | Oui |
| Widget TX15/TX16S | Non |

## Paquet contrôlé

- archive : `JWAIO_BOXER_V0.2.1_Alpha.zip` ;
- 28 fichiers ;
- six scripts Lua ;
- seize sons WAV ;
- dossiers d'installation : `LOGS`, `SCRIPTS` et `SOUNDS` ;
- empreinte SHA-256 : `041e3595afbcfe3c5c7b92b13b5965f8017fe5083f434e9e7fb475d08e8b8e09`.

## État des essais

Le 31 octobre 2026, Charly a confirmé le démarrage du correctif, l'absence de gel et l'audibilité de tous les sons pendant les derniers essais réalisés sans connexion USB.

Les contrôles sur ordinateur couvrent la syntaxe Lua 5.3, les menus, les transitions d'écran, les sauvegardes simulées, le séquencement audio et les contraintes de l'interface monochrome. Ils ne reproduisent pas entièrement le matériel ni le lecteur audio natif de la radio.

L'ensemble des fonctions en vol n'est pas encore déclaré validé. Il reste notamment à poursuivre les essais du Finder, du retour au bilan, du nouveau chronomètre après réarmement, des journaux CSV et des alertes en conditions réelles.

Les tests logiciels seront distingués des essais effectués sur une vraie RadioMaster Boxer.