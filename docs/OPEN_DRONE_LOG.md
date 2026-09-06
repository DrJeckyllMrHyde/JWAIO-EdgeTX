# Utiliser les journaux JWAIO avec Open Drone Log

JWAIO crée un fichier **CSV** — lisible dans Excel ou LibreOffice Calc — pour
chaque armement. Le fichier brut reste la référence et ne doit pas être modifié
sur la carte SD.

Open Drone Log accepte un format CSV normalisé comprenant notamment `time_s`,
`lat`, `lng`, `alt_m` et `distance_to_home_m`. Les noms et unités du journal
JWAIO étant volontairement adaptés à EdgeTX, un convertisseur est fourni dans
`tools/jwaio_to_opendronelog.py`.

## Conversion simple

Avec Python 3 installé, ouvrir un terminal à la racine du projet puis lancer :

```text
python tools/jwaio_to_opendronelog.py "F260903_112000.csv"
```

Le fichier créé porte automatiquement le nom :

```text
F260903_112000-opendronelog.csv
```

Il contient les correspondances suivantes :

| JWAIO | Open Drone Log | Conversion |
|---|---|---|
| elapsed_s (ou date + time) | time_s | secondes écoulées ; horloge monotone en priorité |
| lat | lat | degrés décimaux |
| lon | lng | degrés décimaux |
| altitude | alt_m | altitude ramenée au point de départ |
| distance_home_m | distance_to_home_m | mètres |
| speed | speed_ms | km/h divisés par 3,6 |
| sats | satellites | valeur directe |
| lq | rc_signal | valeur directe |
| pack_v | battery_voltage_v | tension du pack ; voir pack_estimated dans le journal brut |
| throttle_pct | rc_throttle | pourcentage de 0 à 100 |
| flight_mode | flight_mode | nom du mode |

`cell_v` est une tension **par cellule**. Elle est conservée dans une colonne
JWAIO dédiée, mais n'est pas déclarée comme tension totale de batterie afin de
ne pas fausser les graphiques d'Open Drone Log. La colonne séparée
`pack_v` alimente la tension totale ; elle peut être estimée à partir de la
tension cellule et du nombre de cellules configuré.

Dans cette alpha, les journaux de vol portent le préfixe **F**. Les journaux
**E** contiennent les événements de diagnostic et ne se convertissent pas en
trace de vol. Les colonnes supplémentaires du journal F ne bloquent pas le
convertisseur. Sans GPS, aucune trajectoire ne peut être reconstituée.

## Limites

- La précision dépend du GPS, de `GSpd` et de la fréquence télémétrique.
- Les lignes sans coordonnées valides sont conservées avec des champs vides.
- Le convertisseur n'efface et ne remplace jamais le journal source.
- L'import direct du CSV JWAIO brut n'est pas garanti : utiliser la version
  convertie.

Références officielles :

- [Open Drone Log](https://opendronelog.com/)
- [Guide des parseurs personnalisés et format CSV cible](https://github.com/arpanghosh8453/open-dronelog/blob/main/docs/custom_parsers.md)
