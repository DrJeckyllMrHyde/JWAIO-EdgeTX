# JWAIO v0.3.1 Alpha

Alpha testée positivement sur TX15 et TX16S Mk1/Mk2. Fonctionnelle pour tous les usages selon le créateur ; des correctifs mineurs et optimisations restent possibles.

| Radio | Archive | Validation |
|---|---|---|
| TX15 | [Télécharger](JWAIO-v0.3.1-Alpha-TX15.zip?raw=true) | Testée positivement |
| TX16S-Mk1-Mk2 | [Télécharger](JWAIO-v0.3.1-Alpha-TX16S-Mk1-Mk2.zip?raw=true) | Testée positivement |
| TX16S-Mk3 | [Télécharger](JWAIO-v0.3.1-Alpha-TX16S-Mk3.zip?raw=true) | Sans essai physique ; testeurs recherchés |

Mk3 : adaptation aux spécifications matérielles RadioMaster, sans radio physique. EdgeTX 2.12.0 ou supérieur requis ; série 2.12.x visée.

Les trois ZIP sont reconstruits depuis `radios/`, avec les identifiants Alpha et les notices actualisées. La logique du widget est conservée par rapport aux paquets v0.3.1 fournis. Ce reconditionnement ne constitue pas un nouvel essai sur radio.

Copier WIDGETS, SOUNDS et LOGS, directement présents dans chaque ZIP, à la racine du stockage EdgeTX. Installer une seule variante. Les licences et le guide texte sont inclus.

[Guide débutant](../../docs/INSTALLATION.md) · [SHA-256](SHA256SUMS.txt) · [Sources](../../radios/)

## Mise à jour TX15 — 22 septembre 2026

Le paquet TX15 inclut maintenant les effets LED du skin JWAIO activés par défaut. Il provient de la nouvelle archive du créateur ; les anciennes mentions internes ont été harmonisées en Alpha et les notices/ licences incluses. Le code fonctionnel fourni est conservé. Les deux paquets TX16S restent identiques.

[Utiliser les LED et les désactiver](../../docs/SKINS.md#led-du-skin-jwaio-sur-tx15). Aucun nouvel essai physique n’est revendiqué par ces contrôles logiciels.
