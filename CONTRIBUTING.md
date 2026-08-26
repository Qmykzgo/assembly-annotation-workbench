# Contributing

Contributions should preserve the separation between gene prediction, functional evidence, orthology, synteny, completeness, and fragmentation. Any new evidence field should document its source, model/database release, threshold, reference build, and whether it is meaningful in stub mode.

Run the following checks before opening a pull request:

```bash
python3 -m py_compile scripts/*.py
python3 scripts/validate_repo.py
python3 scripts/validate_manifest.py assets/test-data/annotation.csv --check-paths
nextflow run main.nf -profile test -stub-run --outdir results/test
```

Changes to schemas or release states should update the synthetic fixture and documentation. Synthetic output must remain clearly labeled as wiring-only and must not be presented as biological evidence.
