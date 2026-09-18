# Contrôler JWAIO v0.3.1 Alpha

Ces contrôles sur ordinateur ne remplacent pas des essais sur radio. TX15 et TX16S Mk1/Mk2 ont été testés positivement selon le créateur ; Mk3 attend toujours des essais physiques.

Depuis la racine du dépôt, avec Python 3 :

```text
python tests/test_release_package.py
python tests/test_opendronelog_converter.py
```

Le premier contrôle reconstruit les trois ZIP dans un dossier temporaire et compare leur contenu et leurs empreintes aux paquets publiés. Les médias, licences, sources propres à chaque radio et identifiants Alpha sont contrôlés.

Avec Lua 5.2 ou supérieur, exécuter ces quatre tests pour chacun des chemins `radios/TX15`, `radios/TX16S-Mk1-Mk2` et `radios/TX16S-Mk3` :

```text
lua tests/test_alpha_integration.lua radios/TX15
lua tests/test_diagnostics.lua radios/TX15
lua tests/test_telemetry_cadence.lua radios/TX15
lua tests/test_terrain_audio.lua radios/TX15
```

Les tests simulent les API EdgeTX : capteurs absents ou périmés, minuteries, armement, distances, journaux CSV, skins, alertes audio et priorité du Finder. Ils ne valident ni le rendu réel de l'écran, ni les API du firmware sur la radio, ni l'expérience en vol.

Pour reconstruire les archives sans toucher aux paquets publiés : `python tools/build_release.py`. Les résultats sont écrits dans `outputs/v0.3.1/`. Le lanceur PowerShell `tools/build_release.ps1` accepte `-Python` et `-Output`. Le script de sauvegarde des sources est `tools/build_source_backup.ps1`.
