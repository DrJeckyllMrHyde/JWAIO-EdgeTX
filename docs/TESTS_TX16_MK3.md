# Testeurs recherchés — JWAIO v0.3.1 sur TX16S Mk3

Le créateur ne possède pas de TX16S Mk3. Cette variante a été adaptée à partir des spécifications matérielles RadioMaster et n'a pas été testée physiquement. **Nous recherchons des propriétaires de TX16S Mk3 pour confirmer son fonctionnement avec EdgeTX 2.12.0 ou supérieur.** Les archives ciblent la série 2.12.x ; indiquez toujours votre firmware exact.

Les versions TX15 et TX16S Mk1/Mk2 sont testées et fonctionnelles pour tous les usages selon le créateur, avec seulement des correctifs mineurs/optimisations restant possibles. Cela ne valide pas automatiquement la Mk3.

## Avant de commencer

Sauvegardez votre modèle et votre stockage, installez uniquement l'archive Mk3 suivant le [guide](INSTALLATION.md), puis effectuez les premiers essais au sol, hélices retirées. Laissez les effets LED désactivés au départ. Consultez la [clarification 2.12.0 / 3.0.0](COMPATIBILITE.md).

## Contrôles à rapporter

- Démarrage sans erreur Lua ; lecture de la version v0.3.1 Preview-TX16S-Mk3 dans les informations disponibles.
- Interface lisible en plein écran 800 × 480 : textes, panneaux, logo et jauge des gaz.
- ARM, PreArm, Beeper, Flip et RTH associés aux commandes réelles du modèle ; Thr suit la bonne voie.
- Batterie, LQ, RSSI et données GPS cohérents avec les capteurs EdgeTX disponibles.
- Perte puis reprise de télémétrie au sol : `NO_DATA` puis retour des données.
- Minuteries, annonces vocales, entrée/sortie du Finder et retour des alertes lorsque la recherche est inactive.
- Création des journaux dans `/LOGS/JWAIO/`, absence de ralentissement ou de blocage.
- Si la radio dispose d'anneaux LED et que vous choisissez de les essayer ensuite : préciser l'équipement, l'activation optionnelle et le comportement observé. Ne pas lancer plusieurs scripts pilotant les mêmes LED.

La validation physique reste à documenter ; les contrôles avec API simulées rapportés dans le ZIP ne sont pas une validation en vol.

## Format de retour

Ouvrez une [Issue](https://github.com/DrJeckyllMrHyde/JWAIO-EdgeTX/issues) avec le titre « Test Mk3 — JWAIO v0.3.1 — [résultat] » et indiquez :

1. Modèle exact de radio et équipement : Mk3/Mk3 MAX, panneaux et anneaux éventuels.
2. Version complète d'EdgeTX et nom exact du ZIP JWAIO installé.
3. Type de liaison, batterie/nombre de cellules et capteurs disponibles.
4. Contrôles réalisés, ceux réussis et ceux non réalisés.
5. Pour une anomalie : étapes, résultat attendu, résultat observé et message d'erreur complet.
6. Photo de l'écran ou extraits de journaux utiles, après retrait des coordonnées personnelles.

Un retour de bon fonctionnement est aussi utile qu'un signalement de problème. Merci de préciser ce qui a réellement été essayé.
