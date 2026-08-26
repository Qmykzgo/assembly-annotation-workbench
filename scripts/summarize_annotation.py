#!/usr/bin/env python3
"""Aggregate annotation comparison TSV files into TSV and Markdown."""

from __future__ import annotations

import argparse
import csv
from pathlib import Path

FIELDS = [
    "sample", "feature_scope", "annotation_status", "functional_status",
    "orthology_status", "synteny_status", "completeness_status",
    "fragmentation_status", "database_release", "release_status", "note"
]


def read_rows(paths: list[Path]) -> list[dict[str, str]]:
    rows: list[dict[str, str]] = []
    for path in sorted(paths, key=lambda p: p.name):
        with path.open(newline="", encoding="utf-8") as handle:
            reader = csv.DictReader(handle, delimiter="\t")
            missing = set(FIELDS) - set(reader.fieldnames or [])
            if missing:
                raise ValueError(f"{path} is missing columns: {', '.join(sorted(missing))}")
            rows.extend({field: (row.get(field) or "").strip() for field in FIELDS} for row in reader)
    return sorted(rows, key=lambda row: row["sample"])


def write_tsv(path: Path, rows: list[dict[str, str]]) -> None:
    with path.open("w", newline="", encoding="utf-8") as handle:
        writer = csv.DictWriter(handle, fieldnames=FIELDS, delimiter="\t")
        writer.writeheader()
        writer.writerows(rows)


def write_markdown(path: Path, rows: list[dict[str, str]]) -> None:
    columns = FIELDS[:-1]
    with path.open("w", encoding="utf-8") as handle:
        handle.write("# Annotation comparison summary\n\n")
        handle.write("Prediction, functional evidence, orthology, synteny, completeness, and fragmentation are independent axes. `STUB` and `MISSING_EVIDENCE` remain explicit.\n\n")
        handle.write("| " + " | ".join(columns) + " |\n")
        handle.write("| " + " | ".join("---" for _ in columns) + " |\n")
        for row in rows:
            handle.write("| " + " | ".join(row[column].replace("|", "\\|") for column in columns) + " |\n")
        handle.write("\n## Interpretation guardrails\n\n")
        handle.write("Annotation differences are not automatically gene gain/loss, functional differences, phenotype, or evolutionary causality. Review assembly quality, model/database lineage, thresholds, orthology method, and synteny evidence.\n\n")
        for row in rows:
            handle.write(f"- **{row['sample']}**: {row['note']}\n")


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("metrics", nargs="+", type=Path)
    parser.add_argument("--output", required=True, type=Path)
    parser.add_argument("--markdown", required=True, type=Path)
    args = parser.parse_args()
    rows = read_rows(args.metrics)
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.markdown.parent.mkdir(parents=True, exist_ok=True)
    write_tsv(args.output, rows)
    write_markdown(args.markdown, rows)
    print(f"Wrote {len(rows)} annotation comparison rows")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
