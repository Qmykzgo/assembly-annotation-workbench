## Overview

This skill prepares a de novo assembly for annotation and compares the resulting evidence with a related reference using orthology and synteny.

## Prerequisites

- A validated annotation manifest with stable sample names.
- Assembly and reference FASTA files with declared organism context and build identifiers.
- A declared annotation mode and database/model release.
- Approved annotation, similarity, orthology, and synteny tools for real execution.

## Quick Start

- "Run the assemble-annotate-compare workbench in stub mode and verify every evidence state."
- "Compare these annotations while preserving database release and model provenance."
- "Explain whether a gene-count difference could be assembly fragmentation instead of gene gain."
- "Separate orthology evidence from synteny evidence in the report."

## Example Prompts

> "The new assembly has more predicted genes than the reference. What quality and model checks should happen before interpretation?"

> "Show which features are predicted, functionally supported, orthologous, syntenic, fragmented, or unresolved."

> "Review whether these annotations can be compared when their database releases differ."

## What the Agent Will Do

The agent will validate assembly and organism metadata, preserve prediction and database provenance, keep functional annotation separate from orthology and synteny, expose fragmented or missing evidence, and assign a conservative review status.

## Tips

Do not infer organism identity or database release from filenames. A missing feature can reflect absent sequence, prediction failure, masking, fragmentation, model mismatch, or database coverage. Similarity evidence is not experimental proof of function.

## Related Skills

assembly-qc
genome-profiling
pangenome-readiness-workbench
assembly-sv-workbench
