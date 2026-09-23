# Contrôler JWAIO v0.3.1 Alpha

Ces contrôles sur ordinateur ne remplacent pas des essais sur radio. J'ai testé TX15 et TX16S Mk1/Mk2 avec succès ; je recherche encore des testeurs Mk3.

Depuis la racine du dépôt, avec Python 3 :

```text
python tests/test_release_package.py
python tests/test_opendronelog_converter.py
```

Le premier contrôle reconstruit les trois ZIP dans un dossier temporaire et les compare aux paquets publiés. Il vérifie aussi leurs sources, médias, notices, licences, identifiants Alpha et empreintes SHA-256.

Avec Lua 5.2, exécutez ces quatre tests pour chacun des chemins `radios/TX15`, `radios/TX16S-Mk1-Mk2` et `radios/TX16S-Mk3` :

```text
lua tests/test_alpha_integration.lua radios/TX15
lua tests/test_diagnostics.lua radios/TX15
lua tests/test_telemetry_cadence.lua radios/TX15
lua tests/test_terrain_audio.lua radios/TX15
```

Les tests simulent les API EdgeTX : capteurs absents ou périmés, minuteries, armement, distances, journaux CSV, skins, alertes audio et priorité du Finder. Ils ne valident ni le rendu réel de l'écran, ni les API du firmware sur la radio, ni l'expérience en vol.

Pour reconstruire les archives sans toucher aux paquets publiés : `python tools/build_release.py`. Les résultats sont écrits dans `outputs/v0.3.1/`. Le lanceur PowerShell `tools/build_release.ps1` accepte `-Python` et `-Output`. Le script de sauvegarde des sources est `tools/build_source_backup.ps1`.

Pour les nouveaux effets TX15 : `lua tests/test_tx15_leds.lua`. Ce test couvre les valeurs LED par défaut, les limites des indices/couleurs, la cadence, les manches en modes 1 et 2, les priorités, le partage du pilotage et les erreurs API.

Pour reconstruire uniquement TX15 : `python tools/build_release.py --variant TX15`. Les autres ZIP présents dans le dossier de sortie ne sont pas remplacés ; le manifeste SHA-256 est recalculé pour les paquets présents.
