#!/usr/bin/env python3
"""Validate an assemble-annotate-compare manifest."""

from __future__ import annotations

import argparse
import csv
import sys
from pathlib import Path

REQUIRED = {"sample", "assembly_fasta", "reference_fasta", "organism", "annotation_mode", "database_release"}
MODES = {"prokaryotic", "eukaryotic", "transcript_supported", "other"}


def clean(value: str | None) -> str:
    return (value or "").strip()


def validate(path: Path, check_paths: bool) -> list[str]:
    errors: list[str] = []
    try:
        with path.open(newline="", encoding="utf-8") as handle:
            reader = csv.DictReader(handle)
            fields = {clean(field) for field in (reader.fieldnames or [])}
            missing = REQUIRED - fields
            if missing:
                return [f"missing required columns: {', '.join(sorted(missing))}"]
            seen: set[str] = set()
            for line_number, raw in enumerate(reader, start=2):
                row = {clean(key): clean(value) for key, value in raw.items() if key}
                sample = row.get("sample", "")
                if not sample:
                    errors.append(f"line {line_number}: sample is empty")
                elif sample in seen:
                    errors.append(f"line {line_number}: duplicate sample '{sample}'")
                else:
                    seen.add(sample)
                for field in ("assembly_fasta", "reference_fasta", "organism", "annotation_mode", "database_release"):
                    if not row.get(field):
                        errors.append(f"line {line_number}: {field} is required")
                mode = row.get("annotation_mode", "").lower()
                if mode and mode not in MODES:
                    errors.append(f"line {line_number}: annotation_mode must be one of {sorted(MODES)}")
                for field in ("assembly_fasta", "reference_fasta"):
                    value = row.get(field, "")
                    if value and check_paths and not Path(value).expanduser().exists():
                        errors.append(f"line {line_number}: {field} does not exist: {value}")
    except FileNotFoundError:
        errors.append(f"annotation manifest not found: {path}")
    except csv.Error as exc:
        errors.append(f"CSV parsing error: {exc}")
    return errors


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("manifest", type=Path)
    parser.add_argument("--check-paths", action="store_true")
    args = parser.parse_args()
    errors = validate(args.manifest, args.check_paths)
    if errors:
        for error in errors:
            print(f"ERROR: {error}", file=sys.stderr)
        return 1
    print(f"Valid annotation manifest: {args.manifest}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
