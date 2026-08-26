# assembly-annotation-workbench

A reproducible, agent-compatible workflow for turning a de novo assembly into a provenance-aware annotation set and comparing it with a related reference using **gene prediction, functional evidence, orthology, synteny, and assembly-quality context**.

> Annotation is an evidence layer over an assembly. A database hit, predicted gene, orthogroup, or syntenic block is not by itself proof of function, gene gain/loss, phenotype, or evolutionary causality.

## What this repository does

The workflow validates an annotation manifest, profiles assembly identity, emits a Prokka/Bakta/BRAKER-style annotation handoff, records annotation completeness and fragmentation, keeps orthology and synteny as separate comparison layers, and produces a review-oriented report. Synthetic fixtures exercise workflow wiring only.

| Layer | Initial behavior |
|---|---|
| Input gate | Validates sample, assembly, reference, organism, annotation mode, and database release |
| Assembly gate | Preserves FASTA checksum and basic contiguity before annotation |
| Annotation | Emits tool/model/database provenance and predicted feature counts |
| Functional evidence | Preserves database release and evidence mode without overclaiming function |
| Orthology | Emits orthogroup comparison handoff with method and threshold provenance |
| Synteny | Emits collinearity/block comparison handoff separately from orthology |
| Quality | Tracks completeness, fragmentation, partial models, and unresolved status |
| Reporting | Emits TSV and Markdown comparison summaries |
| Provenance | Captures manifest, mode, tools, references, and interpretation guardrails |

## Quick start

```bash
python3 scripts/validate_repo.py
python3 scripts/validate_manifest.py assets/test-data/annotation.csv --check-paths
nextflow run main.nf -profile test -stub-run --outdir results/test
```

A real run must use site-approved tools, references, and database releases:

```bash
python3 scripts/validate_manifest.py path/to/annotation.csv --check-paths
nextflow run main.nf \
  -profile docker \
  --input path/to/annotation.csv \
  --outdir results/my_annotation_project \
  -resume
```

## Annotation manifest contract

Each row represents an assembly and an explicit comparison reference. Required fields are `sample`, `assembly_fasta`, `reference_fasta`, `organism`, `annotation_mode`, and `database_release`.

```csv
sample,assembly_fasta,reference_fasta,organism,annotation_mode,database_release,reference_build,comparison_group
sample_A,assets/test-data/sample_A.fa,assets/test-data/reference.fa,synthetic_bacterium,prokaryotic,syn-db-1,synthetic-v1,benchmark
sample_B,assets/test-data/sample_B.fa,assets/test-data/reference.fa,synthetic_bacterium,prokaryotic,syn-db-1,synthetic-v1,benchmark
```

Do not infer organism identity, species relationship, or annotation database from filenames. Preserve the declared model and database release in provenance.

## Evidence states

| State | Meaning |
|---|---|
| `AVAILABLE` | Evidence or metadata was supplied and processed by the real route |
| `MISSING_EVIDENCE` | A required database, model, reference, or quality layer was not supplied |
| `NOT_APPLICABLE` | The layer is outside the declared design |
| `FRAGMENTED` | Evidence exists but assembly or annotation fragmentation limits interpretation |
| `STUB` | Synthetic wiring only; no biological claim |
| `REVIEW` | Evidence is present but requires human review |
| `READY_FOR_REVIEW` | Provenance and independent annotation/comparison layers are auditable |

## Interpretation guardrails

Annotation counts must be interpreted alongside assembly completeness, contiguity, gene-model fragmentation, database lineage, and search thresholds. An orthogroup difference is not automatically a gene gain/loss event. A missing annotation may reflect sequence absence, gene prediction failure, assembly fragmentation, database coverage, or threshold choice. Synteny supports collinearity evidence, not function or causality.

## Output layout

```text
results/<project>/
├── 01_assembly/
├── 02_annotation/
├── 03_orthology/
├── 04_synteny/
├── 05_quality/
├── 06_reports/
│   ├── annotation_comparison_summary.tsv
│   └── annotation_comparison_summary.md
└── provenance/
```

## Limitations and safety

The included FASTA fixtures are synthetic and make no biological claim. Stub results do not predict real genes or establish orthology/synteny. This repository does not make clinical, pathogenicity, functional, evolutionary, or phenotype claims.

## Roadmap

Future extensions may add concrete Prokka, Bakta, BRAKER, Funannotate, InterProScan, eggNOG-mapper, OrthoFinder, MCScanX, minimap2, and whole-genome alignment routes. Each extension should preserve tool versions, model/database releases, thresholds, and source identifiers.

## References

[1]: https://github.com/GPTomics/bioSkills "GPTomics bioSkills"
[2]: https://github.com/tseemann/prokka "Prokka"
[3]: https://github.com/oschwengers/bakta "Bakta"
[4]: https://github.com/davidemms/OrthoFinder "OrthoFinder"
[5]: https://doi.org/10.1093/bioinformatics/bty539 "OrthoFinder"
