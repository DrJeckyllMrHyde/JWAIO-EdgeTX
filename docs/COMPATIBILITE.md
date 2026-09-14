# JWAIO v0.3.1 — compatibilité et état des essais

| Variante | Affichage ciblé | Firmware demandé | Validation du widget |
|---|---|---|---|
| TX15 / TX15 Max | 480 × 320 | EdgeTX 2.12.x | Testé et fonctionnel pour tous les usages, selon le créateur |
| TX16S Mk1 / Mk2 | 480 × 272 | EdgeTX 2.12.x | Testé et fonctionnel pour tous les usages, selon le créateur |
| TX16S Mk3 | 800 × 480 | EdgeTX 2.12.0 ou supérieur ; série 2.12.x visée | Aucun essai physique ; testeurs recherchés |

Sur TX15 et Mk1/Mk2, seuls des correctifs mineurs et des optimisations restent possibles. Ce bilan reprend la déclaration du créateur ; la mise en ligne n'ajoute pas de nouveaux essais sur radio.

Pour Mk3, le créateur ne possède pas la radio. Le widget a été adapté à partir des spécifications matérielles RadioMaster. Les contrôles logiciels mentionnés dans l'archive ne remplacent pas un essai physique. Il faut confirmer l'affichage, les commandes, les sons, la télémétrie, les journaux et la stabilité sur la version exacte d'EdgeTX utilisée.

## Pourquoi la notice Mk3 parle-t-elle de 3.0.0 ?

Le ZIP original contient une mention « EdgeTX 3.0.0 minimum » dans `LIRE_AVANT_INSTALLATION.txt`, `CHANGELOG_Mk3.md` et les documents d'audit. La fiche produit [RadioMaster TX16S Mk3](https://radiomasterrc.com/products/tx16s-mk3-radio-controller) affiche également cette indication lors de la vérification du 14 septembre 2026.

Cependant, les [notes officielles d'EdgeTX v2.12.0](https://github.com/EdgeTX/edgetx/releases/tag/v2.12.0) incluent explicitement la TX16S Mk3 parmi les nouvelles radios et présentent 2.12 comme la série stable destinée notamment aux radios STM32H7, après report de la nouvelle interface 3.0. La [page de téléchargements RadioMaster](https://radiomasterrc.com/pages/firmware-updates) propose aussi des contenus SD Mk3 2.12.0.

La documentation du dépôt retient donc **EdgeTX 2.12.0 ou supérieur**, conformément au périmètre demandé par le créateur. Cela ne certifie pas le widget sur toutes les versions ultérieures : utilisez le firmware correspondant exactement à votre radio et communiquez son numéro complet lors des essais. Il n'est pas nécessaire d'installer 3.0 uniquement à cause de la mention ancienne du ZIP.

Les ZIP sont conservés **strictement à l'identique**, y compris leurs notices historiques et leurs identifiants internes Preview. Cette page apporte la clarification sans modifier les archives originales. Les fichiers `config.lua` annoncent tous `version = "0.3.1"` ; certains commentaires d'en-tête restent à 0.3.0.

## Participer aux essais

Les propriétaires de TX16S Mk3 sont invités à suivre la [fiche de validation](TESTS_TX16_MK3.md). Une réussite sur un modèle de radio ou un firmware ne doit pas être extrapolée automatiquement aux autres variantes.
