#!/usr/bin/env python3
"""Convertit un journal CSV JWAIO vers le format CSV Open Drone Log.

Usage :
    python tools/jwaio_to_opendronelog.py FICHIER_JWAIO.csv [SORTIE.csv]

Le script utilise uniquement la bibliotheque standard de Python. Il ne modifie
jamais le fichier source et laisse vides les mesures absentes ou invalides.
"""

from __future__ import annotations

import csv
import json
import sys
from datetime import datetime
from pathlib import Path


REQUIRED_INPUT = {
    "date",
    "time",
    "lat",
    "lon",
    "altitude",
    "speed",
    "cell_v",
    "distance_home_m",
    "distance_total_m",
    "distance_max_m",
    "lq",
    "sats",
}

OUTPUT_FIELDS = [
    "time_s",
    "lat",
    "lng",
    "alt_m",
    "distance_to_home_m",
    "speed_ms",
    "satellites",
    "rc_signal",
    "jwaio_cell_v",
    "jwaio_total_distance_m",
    "jwaio_max_distance_m",
    "Metadata",
]


def number(value: str) -> float | None:
    """Retourne un nombre fini ou None sans interrompre la conversion."""
    value = (value or "").strip().replace(",", ".")
    if not value:
        return None
    try:
        result = float(value)
    except ValueError:
        return None
    if result != result or result in (float("inf"), float("-inf")):
        return None
    return result


def text_number(value: float | None, digits: int = 3) -> str:
    if value is None:
        return ""
    return f"{value:.{digits}f}".rstrip("0").rstrip(".")


def parse_datetime(row: dict[str, str]) -> datetime | None:
    raw = f"{row.get('date', '')} {row.get('time', '')}".strip()
    try:
        return datetime.strptime(raw, "%Y-%m-%d %H:%M:%S")
    except ValueError:
        return None


def convert(input_path: Path, output_path: Path) -> int:
    if input_path.resolve() == output_path.resolve():
        raise ValueError("Le fichier de sortie doit etre different du fichier source.")

    with input_path.open("r", encoding="utf-8-sig", newline="") as source:
        reader = csv.DictReader(source)
        headers = set(reader.fieldnames or [])
        missing = sorted(REQUIRED_INPUT - headers)
        if missing:
            raise ValueError("Colonnes JWAIO absentes : " + ", ".join(missing))
        rows = list(reader)

    first_time = next((parse_datetime(row) for row in rows if parse_datetime(row)), None)
    first_altitude = next((number(row.get("altitude", "")) for row in rows
                           if number(row.get("altitude", "")) is not None), None)

    metadata = json.dumps(
        {
            "drone_model": "Custom FPV / JWAIO",
            "start_time": first_time.isoformat() if first_time else "",
            "notes": "Journal converti par JWAIO V0.2.1",
            "tags": [{"tag": "FPV", "tag_type": "manual"}],
        },
        ensure_ascii=False,
        separators=(",", ":"),
    )

    output_path.parent.mkdir(parents=True, exist_ok=True)
    with output_path.open("w", encoding="utf-8", newline="") as target:
        writer = csv.DictWriter(target, fieldnames=OUTPUT_FIELDS)
        writer.writeheader()

        for index, row in enumerate(rows):
            timestamp = parse_datetime(row)
            elapsed = (timestamp - first_time).total_seconds() if timestamp and first_time else None
            altitude = number(row.get("altitude", ""))
            relative_altitude = (
                altitude - first_altitude
                if altitude is not None and first_altitude is not None
                else None
            )
            speed_kmh = number(row.get("speed", ""))

            writer.writerow(
                {
                    "time_s": text_number(max(0.0, elapsed), 1) if elapsed is not None else "",
                    "lat": text_number(number(row.get("lat", "")), 7),
                    "lng": text_number(number(row.get("lon", "")), 7),
                    "alt_m": text_number(relative_altitude, 1),
                    "distance_to_home_m": text_number(number(row.get("distance_home_m", "")), 1),
                    "speed_ms": text_number(speed_kmh / 3.6, 3) if speed_kmh is not None else "",
                    "satellites": text_number(number(row.get("sats", "")), 0),
                    "rc_signal": text_number(number(row.get("lq", "")), 0),
                    "jwaio_cell_v": text_number(number(row.get("cell_v", "")), 2),
                    "jwaio_total_distance_m": text_number(number(row.get("distance_total_m", "")), 1),
                    "jwaio_max_distance_m": text_number(number(row.get("distance_max_m", "")), 1),
                    "Metadata": metadata if index == 0 else "",
                }
            )

    return len(rows)


def main(argv: list[str]) -> int:
    if len(argv) not in (2, 3):
        print("Usage: python jwaio_to_opendronelog.py ENTREE.csv [SORTIE.csv]", file=sys.stderr)
        return 2

    input_path = Path(argv[1]).expanduser()
    output_path = (
        Path(argv[2]).expanduser()
        if len(argv) == 3
        else input_path.with_name(input_path.stem + "-opendronelog.csv")
    )

    try:
        count = convert(input_path, output_path)
    except (OSError, ValueError) as exc:
        print(f"Erreur : {exc}", file=sys.stderr)
        return 1

    print(f"Conversion terminee : {count} lignes -> {output_path}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv))

