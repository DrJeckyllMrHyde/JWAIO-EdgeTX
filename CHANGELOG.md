# Notes de version

## JWAIO v0.3.1 — 14 septembre 2026

- Publication des trois archives originales : TX15, TX16S Mk1/Mk2 et TX16S Mk3, ciblant EdgeTX 2.12.x.
- TX15 et Mk1/Mk2 testés et fonctionnels pour tous les usages selon le créateur ; correctifs mineurs et optimisations restant possibles.
- Mk3 adaptée aux spécifications RadioMaster, sans radio physique ; EdgeTX 2.12.0 ou supérieur requis et testeurs recherchés.
- Guides débutants réécrits : choix du ZIP, dossier intermédiaire Mk1/Mk2, stockage EdgeTX, découverte des capteurs, dix options, minuteries et dépannage.
- Documentation alignée sur les paquets : SA bas pour ANGLE ; satellites 0–4 rouge, 5–6 orange, 7+ vert ; annonces satellites et priorité Finder précisées.
- Note expliquant l'ancienne mention EdgeTX 3.0.0 dans les notices Mk3, avec sources officielles ; archives non modifiées.
- Empreintes SHA-256 publiées. Les identifiants internes Preview sont conservés.
- Ancienne archive, release alpha et sources sdcard préservées ; sdcard identifié comme historique et distinct des paquets v0.3.1.

Voir les [archives v0.3.1](releases/v0.3.1/README.md), la [compatibilité](docs/COMPATIBILITE.md) et l'[appel aux testeurs Mk3](docs/TESTS_TX16_MK3.md).

## JWAIO 0.3_Alpha — 6 septembre 2026

- Système de skins : fond, logo et couleurs, avec sélection dans le menu.
- Capteur RQly automatique pour conserver dix options.
- Correction de l'alternance intempestive entre mesures et NO_DATA.
- Alertes batterie stabilisées, filtrage des creux brefs et sons allégés.
- Alerte Alt > 120 m, moteurs armés, une fois par armement.
- Qwad Finder réactif et prioritaire pendant la recherche.
- Journaux enrichis, diagnostic des événements audio et export Open Drone Log.
- Contrôle de l'affichage sans GPS, des timers et des sauvegardes.

Base technique : 0.3.0, correctif alpha-2 validé sur la radio du créateur.
Publication alpha destinée aux retours de la communauté.
