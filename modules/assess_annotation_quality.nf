process ASSESS_ANNOTATION_QUALITY {
    tag "${meta.sample}"
    publishDir "${params.outdir}/05_quality", mode: 'copy'

    input:
    tuple val(meta), path(profile), path(annotation_quality)

    output:
    tuple val(meta), path("${meta.sample}.quality.tsv"), emit: quality

    script:
    """
    printf 'sample\\tcompleteness_status\\tfragmentation_status\\tpartial_gene_status\\tquality_status\\tnote\\n' > ${meta.sample}.quality.tsv
    printf '${meta.sample}\\tREVIEW\\tREVIEW\\tREQUIRED\\tREVIEW\\tReal execution must combine assembly completeness, contiguity, partial models, and annotation evidence\\n' >> ${meta.sample}.quality.tsv
    """

    stub:
    """
    printf 'sample\\tcompleteness_status\\tfragmentation_status\\tpartial_gene_status\\tquality_status\\tnote\\n' > ${meta.sample}.quality.tsv
    printf '${meta.sample}\\tSTUB\\tSTUB\\tSTUB\\tSTUB\\tSynthetic wiring only; no completeness or fragmentation claim\\n' >> ${meta.sample}.quality.tsv
    """
}
