process WRITE_PROVENANCE {
    publishDir params.outdir, mode: 'copy', pattern: 'provenance/*'

    input:
    path manifest

    output:
    path 'provenance'

    script:
    """
    mkdir -p provenance
    cp ${manifest} provenance/annotation_manifest.csv
    cat > provenance/run_context.tsv <<'EOF'
field	value
workflow	assembly-annotation-workbench
mode	${params.mode}
nextflow_version	${workflow.nextflow.version}
annotation_route	declared Prokka/Bakta/BRAKER-style handoff
functional_evidence	database release and evidence mode must remain traceable
orthology	kept separate from annotation presence and synteny
synteny	collinearity evidence; not a function or causality claim
quality	completeness and fragmentation remain visible before interpretation
stub_guardrail	STUB output is wiring-only and makes no biological claim
EOF
    """
}
