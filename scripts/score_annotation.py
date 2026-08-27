#!/usr/bin/env python3
"""Score deterministic annotation comparison counts and write an evidence report."""

from __future__ import annotations

import argparse
import csv
from pathlib import Path

FIELDS = [
    "sample", "tool", "feature_scope", "database_release", "reference_features",
    "predicted_features", "matched_features", "partial_features", "unannotated_reference",
    "orthogroup_matches", "synteny_blocks", "feature_precision", "feature_recall",
    "fragmentation_rate", "orthology_status", "synteny_status", "release_status", "note"
]
REQUIRED = set(FIELDS[:11]) | {"orthology_status", "synteny_status", "release_status", "note"}


def ratio(numerator: int, denominator: int) -> str:
    return f"{numerator / denominator:.4f}" if denominator else "NA"


def score_row(row: dict[str, str]) -> dict[str, str]:
    try:
        reference = int(row["reference_features"])
        predicted = int(row["predicted_features"])
        matched = int(row["matched_features"])
        partial = int(row["partial_features"])
        unannotated = int(row["unannotated_reference"])
    except (KeyError, ValueError) as exc:
        raise ValueError(f"invalid annotation count: {exc}") from exc
    if min(reference, predicted, matched, partial, unannotated) < 0:
        raise ValueError("annotation counts must be non-negative")
    if matched > min(reference, predicted):
        raise ValueError("matched_features cannot exceed reference or predicted features")
    return {
        **{key: row.get(key, "").strip() for key in FIELDS[:11]},
        "feature_precision": ratio(matched, predicted),
        "feature_recall": ratio(matched, reference),
        "fragmentation_rate": ratio(partial, predicted),
        "orthology_status": row["orthology_status"].strip(),
        "synteny_status": row["synteny_status"].strip(),
        "release_status": row["release_status"].strip(),
        "note": row["note"].strip(),
    }


def read_rows(path: Path) -> list[dict[str, str]]:
    with path.open(newline="", encoding="utf-8") as handle:
        reader = csv.DictReader(handle, delimiter="\t")
        missing = REQUIRED - set(reader.fieldnames or [])
        if missing:
            raise ValueError(f"{path} is missing columns: {', '.join(sorted(missing))}")
        return [score_row(row) for row in reader]


def write_tsv(path: Path, rows: list[dict[str, str]]) -> None:
    with path.open("w", newline="", encoding="utf-8") as handle:
        writer = csv.DictWriter(handle, fieldnames=FIELDS, delimiter="\t")
        writer.writeheader()
        writer.writerows(rows)


def write_markdown(path: Path, rows: list[dict[str, str]]) -> None:
    with path.open("w", encoding="utf-8") as handle:
        handle.write("# ANNT annotation-quality summary\n\n")
        handle.write("Feature precision/recall and fragmentation are conditional on the reference annotation, matching rule, model/database release, and input assembly. Orthology and synteny remain separate evidence layers. `STUB` output is wiring-only.\n\n")
        columns = FIELDS
        handle.write("| " + " | ".join(columns) + " |\n")
        handle.write("| " + " | ".join("---" for _ in columns) + " |\n")
        for row in rows:
            handle.write("| " + " | ".join(row[column].replace("|", "\\|") for column in columns) + " |\n")
        handle.write("\n## Interpretation guardrails\n\n")
        handle.write("A feature mismatch is not automatically gene gain/loss. Review assembly completeness, model compatibility, masking, database coverage, orthology, and synteny before biological interpretation.\n")


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("fixture", type=Path)
    parser.add_argument("--output", required=True, type=Path)
    parser.add_argument("--markdown", required=True, type=Path)
    args = parser.parse_args()
    rows = read_rows(args.fixture)
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.markdown.parent.mkdir(parents=True, exist_ok=True)
    write_tsv(args.output, rows)
    write_markdown(args.markdown, rows)
    print(f"Wrote {len(rows)} ANNT annotation-quality rows")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
