# Compatibilité et validation

## Cible

| Élément | État |
|---|---|
| RadioMaster Boxer | Démarrage, stabilité hors USB et sons validés par Charly |
| Écran monochrome 128 × 64 | Interface dédiée |
| EdgeTX | 2.12.2 |
| Script TOOLS | Oui |

## Paquet contrôlé

- archive : `JWAIO_BOXER_V0.2.1_Alpha.zip` ;
- 29 fichiers ;
- six scripts Lua ;
- seize sons WAV ;
- dossiers d'installation : `LOGS`, `SCRIPTS` et `SOUNDS` ;
- empreinte SHA-256 : `f6e31a050aa4879e4e7c1ef428bcdced4df18babb9849528ae130509877e0217`.

## État des essais

Le correctif du 1er novembre 2026 a réussi les contrôles Lua 5.3, les tests audio/UI, les scénarios de refus SD et deux simulations de bilan de quinze minutes. Il réduit les allocations audio, évite l'ouverture des WAV par Lua et conserve les statistiques en attente après un refus de sauvegarde.

Les tests logiciels restent distincts des essais effectués sur une vraie radio et en conditions de vol.
