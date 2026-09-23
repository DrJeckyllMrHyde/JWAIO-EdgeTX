# JWAIO v0.3.1 Alpha — compatibilité

J'ai testé JWAIO sur TX15 et TX16S Mk1/Mk2 avec succès. Ces versions sont fonctionnelles pour tous les usages ; de petits correctifs et des optimisations restent possibles.

| Radio | Écran | Firmware | État des essais |
|---|---|---|---|
| TX15 / TX15 Max | 480 × 320 | EdgeTX 2.12.x | Testée positivement |
| TX16S Mk1 / Mk2 | 480 × 272 | EdgeTX 2.12.x | Testée positivement |
| TX16S Mk3 | 800 × 480 | EdgeTX 2.12.0 ou supérieur ; série 2.12.x visée | Pas d'essai physique |

Je ne possède pas de TX16S Mk3. J'ai adapté le widget à partir des spécifications matérielles de RadioMaster, mais je recherche des testeurs pour vérifier son fonctionnement sur cette radio. Il reste à confirmer l'affichage, les commandes, les sons, la télémétrie, les journaux et la stabilité.

## Ce que signifie Alpha

La v0.3.1 est la base actuelle du projet. Le statut Alpha permet encore des corrections et des améliorations. Les essais réussis sur TX15 et Mk1/Mk2 ne valident pas automatiquement la Mk3 ni toutes les futures versions d'EdgeTX.

Les contrôles logiciels complètent les essais sur radio ; ils ne les remplacent pas. Les LED sont activées par défaut sur TX15 et désactivées sur les variantes TX16S.

## M'aider à tester la Mk3

Si vous possédez cette radio, vous pouvez suivre la [fiche d'essais](TESTS_TX16_MK3.md). Pensez à indiquer la version exacte d'EdgeTX et le paquet JWAIO utilisé.
