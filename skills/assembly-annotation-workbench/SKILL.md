---
name: assembly-annotation-workbench
description: Plans and interprets de novo assembly annotation, functional evidence, orthology, synteny, and annotation-quality comparison. Use when an agent must turn an assembly into a provenance-aware gene set or compare annotations without overclaiming gene function or evolutionary meaning.
tool_type: mixed
primary_tool: Nextflow
workflow: true
depends_on:
  - assembly-qc
  - genome-profiling
  - pangenome-readiness-workbench
qc_checkpoints:
  assembly: "FASTA identity, checksum, contiguity, and organism context are explicit"
  annotation: "Prediction tool, model, database release, evidence mode, and thresholds are retained"
  comparison: "Orthology and synteny remain separate layers with reference and method provenance"
  release: "Completeness, fragmentation, missing evidence, and interpretation limits are reviewed"
---

## Version Compatibility

Reference examples assume Nextflow 24.04+, Prokka 1.14+, Bakta 1.9+, BRAKER 3+, InterProScan 5.70+, eggNOG-mapper 2.1+, OrthoFinder 2.5+, minimap2 2.28+, and MCScanX or another declared synteny method. Verify the installed versions and database/model releases before a real run.

# Assembly annotation and comparison

**Goal:** Convert a de novo assembly into a traceable annotation set and compare it with a related reference while separating prediction, functional evidence, orthology, synteny, and quality.

**Principle:** an annotation is conditional on the assembly, prediction model, database release, search thresholds, and evidence source.

## Manifest contract

| Field | Required | Purpose |
|---|---:|---|
| `sample` | yes | Stable sample key across all outputs |
| `assembly_fasta` | yes | Assembly to annotate |
| `reference_fasta` | yes | Declared comparison reference |
| `organism` | yes | Context for model and interpretation |
| `annotation_mode` | yes | Prokaryotic, eukaryotic, transcript-supported, or other explicit route |
| `database_release` | yes | Reproducible functional evidence lineage |
| `reference_build` | recommended | Prevents incompatible comparisons |
| `comparison_group` | recommended | Declares the comparison design |

Never infer organism, species relationship, model, or database from filenames.

## Evidence layers

| Layer | Question | Main caution |
|---|---|---|
| Gene prediction | Where might genes be? | Model and assembly fragmentation affect predictions |
| Functional annotation | What known evidence matches? | Similarity/database hit is not proof of function |
| Orthology | Which genes may share ancestry? | One-to-one, one-to-many, and paralogy require context |
| Synteny | Which regions are collinear? | Collinearity does not establish function or causality |
| Completeness | How much expected sequence/gene content is represented? | Database choice and taxon breadth affect estimates |
| Fragmentation | Are genes split or partial? | Contiguity and annotation filters can change counts |

Do not collapse these into a single annotation score without retaining the component evidence.

## Annotation provenance

Preserve source FASTA checksum, contig naming, annotation tool/version, model parameters, database release, evidence tracks, masking decisions, minimum hit thresholds, and output file checksums. A predicted feature must be traceable to its source contig and annotation route.

If a tool uses a reference species or training model, record it explicitly. A model mismatch can create systematic false negatives, false positives, or fragmented gene models.

## Orthology and synteny

Orthology methods infer relationships from sequence and/or species-tree context. Preserve software, input proteomes, species set, search thresholds, inflation or clustering parameters, and whether gene models are complete. Do not call a gene gained or lost because it is absent from one annotation alone.

Synteny methods depend on gene order, anchors, genome alignment, and filtering. Preserve block thresholds, strand/orientation rules, and unresolved intervals. Treat discordance between orthology and synteny as a review signal rather than forcing agreement.

## Annotation-quality review

| State | Meaning |
|---|---|
| `AVAILABLE` | Evidence was supplied and processed by the real route |
| `MISSING_EVIDENCE` | Required model, database, reference, or quality layer is unavailable |
| `FRAGMENTED` | Evidence exists but assembly or gene models are incomplete |
| `NOT_APPLICABLE` | Layer is outside the declared design |
| `STUB` | Synthetic wiring only; no biological claim |
| `REVIEW` | Evidence exists but interpretation requires review |
| `READY_FOR_REVIEW` | Provenance and independent evidence layers are auditable |

A `READY_FOR_REVIEW` state does not imply function, phenotype, causality, evolutionary adaptation, pathogenicity, or clinical significance.

## Failure modes

### Annotation count is treated as gene content

**Trigger:** A higher predicted-gene count is called biological expansion.

**Fix:** Review assembly completeness, fragmentation, model/database release, partial genes, and orthology evidence.

### Database hits are treated as functional proof

**Trigger:** A similarity match is reported as confirmed function.

**Fix:** Preserve accession, evidence channel, identity/coverage thresholds, review status, and experimental limitations.

### Orthology and synteny are conflated

**Trigger:** A collinear block is described as an orthologous gene relationship.

**Fix:** Keep orthology, gene order, and sequence similarity as separate evidence layers.

### Missing annotation is treated as absence

**Trigger:** No feature in one GFF3 is interpreted as biological loss.

**Fix:** Check assembly presence, prediction sensitivity, masking, database coverage, and model compatibility.

## Common errors

| Symptom | Likely cause | Fix |
|---|---|---|
| Gene count changes sharply | Model, masking, or database version changed | Pin and record all annotation inputs |
| Many partial genes | Fragmented assembly or unsuitable model | Review contiguity, completeness, and training context |
| Orthogroups are unstable | Input proteomes or thresholds differ | Preserve exact inputs and search/clustering parameters |
| Synteny blocks are too short | Anchor density or filtering is too strict | Report thresholds and unresolved regions |
| Function labels are overconfident | Unreviewed/weak similarity hits | Separate evidence from inference and cite accessions |

## References

- Seemann T. 2014. Prokka: rapid prokaryotic genome annotation. *Bioinformatics* 30:2068–2069 [1].
- Schwacke R, et al. 2021. Bakta: rapid and standardized annotation of bacterial genomes. *Microbial Genomics* 7 [2].
- Emms DM, Kelly S. 2019. OrthoFinder: phylogenetic orthology inference for comparative genomics. *Genome Biology* 20:238 [3].

[1]: https://doi.org/10.1093/bioinformatics/btu153 "Prokka"
[2]: https://doi.org/10.1099/mgen.0.000685 "Bakta"
[3]: https://doi.org/10.1186/s13059-019-1832-y "OrthoFinder"

## Related Skills

assembly-qc
genome-profiling
pangenome-readiness-workbench
assembly-sv-workbench
