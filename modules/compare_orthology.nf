process COMPARE_ORTHOLOGY {
    tag "${meta.sample}"
    publishDir "${params.outdir}/03_orthology", mode: 'copy'

    input:
    tuple val(meta), path(annotation)

    output:
    tuple val(meta), path("${meta.sample}.orthology.tsv"), emit: orthology

    script:
    """
    printf 'sample\\torthology_status\\tmethod\\tcomparison_group\\tsearch_thresholds\\torthogroup_status\\tnote\\n' > ${meta.sample}.orthology.tsv
    printf '${meta.sample}\\tREVIEW\\tOrthoFinder-handoff\\t${meta.comparison_group}\\tREQUIRED\\tREQUIRED\\tOrthology is separate from annotation presence and requires exact input proteomes and parameters\\n' >> ${meta.sample}.orthology.tsv
    """

    stub:
    """
    printf 'sample\\torthology_status\\tmethod\\tcomparison_group\\tsearch_thresholds\\torthogroup_status\\tnote\\n' > ${meta.sample}.orthology.tsv
    printf '${meta.sample}\\tSTUB\\tSTUB\\t${meta.comparison_group}\\tSTUB\\tSTUB\\tSynthetic wiring only; no orthology inference or gene gain/loss claim\\n' >> ${meta.sample}.orthology.tsv
    """
}
