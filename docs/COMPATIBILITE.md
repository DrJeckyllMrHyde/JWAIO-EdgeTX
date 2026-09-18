# JWAIO v0.3.1 Alpha — compatibilité et état des essais

| Variante | Affichage ciblé | Firmware demandé | Validation du widget |
|---|---|---|---|
| TX15 / TX15 Max | 480 × 320 | EdgeTX 2.12.x | Testé et fonctionnel pour tous les usages, selon le créateur |
| TX16S Mk1 / Mk2 | 480 × 272 | EdgeTX 2.12.x | Testé et fonctionnel pour tous les usages, selon le créateur |
| TX16S Mk3 | 800 × 480 | EdgeTX 2.12.0 ou supérieur ; série 2.12.x visée | Aucun essai physique ; testeurs recherchés |

Sur TX15 et Mk1/Mk2, seuls des correctifs mineurs et des optimisations restent possibles. Ce bilan reprend la déclaration du créateur ; la mise en ligne n'ajoute pas de nouveaux essais sur radio.

Pour Mk3, le créateur ne possède pas la radio. Le widget a été adapté à partir des spécifications matérielles RadioMaster. Les contrôles logiciels ne remplacent pas un essai physique. Il faut confirmer l'affichage, les commandes, les sons, la télémétrie, les journaux et la stabilité sur la version exacte d'EdgeTX utilisée.

## Statut Alpha

TX15 et TX16S Mk1/Mk2 constituent la base testée positivement. Mk3 reste une adaptation à valider sur le matériel réel. La série EdgeTX visée est 2.12.x ; le minimum demandé pour Mk3 est 2.12.0, sans validation automatique de toutes les versions ultérieures.

Les archives Alpha contiennent les sources v0.3.1 et des notices cohérentes avec ce périmètre. La logique des trois variantes fournies est conservée ; seules les informations de version et les notices ont été actualisées.

## Participer aux essais

Les propriétaires de TX16S Mk3 sont invités à suivre la [fiche de validation](TESTS_TX16_MK3.md).
