"""Test minimal du convertisseur JWAIO vers Open Drone Log."""

from __future__ import annotations

import csv
import importlib.util
import tempfile
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
SCRIPT = ROOT / "tools" / "jwaio_to_opendronelog.py"
SPEC = importlib.util.spec_from_file_location("jwaio_converter", SCRIPT)
assert SPEC and SPEC.loader
MODULE = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(MODULE)


def main() -> None:
    source_text = "\n".join(
        [
            "date,time,lat,lon,altitude,speed,cell_v,distance_home_m,distance_total_m,distance_max_m,lq,sats",
            "2026-09-03,11:20:00,48.1234567,5.1234567,238.0,0.0,4.12,0.0,0.0,0.0,100,10",
            "2026-09-03,11:20:01,48.1234667,5.1234667,240.5,36.0,4.05,12.3,10.0,12.3,95,11",
        ]
    )

    with tempfile.TemporaryDirectory() as directory:
        folder = Path(directory)
        source = folder / "flight.csv"
        target = folder / "flight-opendronelog.csv"
        source.write_text(source_text + "\n", encoding="utf-8")

        count = MODULE.convert(source, target)
        assert count == 2

        with target.open("r", encoding="utf-8", newline="") as handle:
            rows = list(csv.DictReader(handle))

        assert rows[0]["time_s"] == "0"
        assert rows[1]["time_s"] == "1"
        assert rows[1]["lng"] == "5.1234667"
        assert rows[1]["alt_m"] == "2.5"
        assert rows[1]["distance_to_home_m"] == "12.3"
        assert rows[1]["speed_ms"] == "10"
        assert rows[1]["satellites"] == "11"
        assert rows[1]["rc_signal"] == "95"
        assert rows[0]["Metadata"]
        assert rows[1]["Metadata"] == ""

        # Alpha : colonnes supplementaires, horloge monotone, pas de faux GPS.
        fields = sorted(MODULE.REQUIRED_INPUT) + ["elapsed_s", "pack_v", "throttle_pct",
                                                "flight_mode", "diagnostic_extra"]
        with source.open("w", encoding="utf-8", newline="") as handle:
            writer = csv.DictWriter(handle, fieldnames=fields)
            writer.writeheader()
            writer.writerow(dict(date="2026-09-06", time="12:00:00", elapsed_s="0",
                                 cell_v="3.9", pack_v="23.4", throttle_pct="5", flight_mode="ACRO"))
            writer.writerow(dict(date="2026-09-06", time="11:59:59", elapsed_s="1.25",
                                 altitude="0", speed="0", diagnostic_extra="ignored"))
        original = source.read_bytes()
        assert MODULE.convert(source, target) == 2
        with target.open(encoding="utf-8", newline="") as handle:
            rows = list(csv.DictReader(handle))
        assert rows[0]["battery_voltage_v"] == "23.4"
        assert rows[0]["rc_throttle"] == "5" and rows[0]["flight_mode"] == "ACRO"
        assert rows[1]["time_s"] == "1.2"  # Presentation au dixieme.
        assert rows[1]["alt_m"] == "0" and rows[1]["speed_ms"] == "0"
        assert all(row["lat"] == row["lng"] == "" for row in rows)
        assert rows[1]["battery_voltage_v"] == rows[1]["rc_throttle"] == ""
        assert source.read_bytes() == original

    print("Open Drone Log converter: OK")


if __name__ == "__main__":
    main()
