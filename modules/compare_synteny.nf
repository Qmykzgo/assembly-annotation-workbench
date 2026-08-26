process COMPARE_SYNTENY {
    tag "${meta.sample}"
    publishDir "${params.outdir}/04_synteny", mode: 'copy'

    input:
    tuple val(meta), path(assembly), path(reference)

    output:
    tuple val(meta), path("${meta.sample}.synteny.tsv"), emit: synteny

    script:
    """
    printf 'sample\\tsynteny_status\\tmethod\\treference_build\\tanchor_status\\tblock_status\\tnote\\n' > ${meta.sample}.synteny.tsv
    printf '${meta.sample}\\tREVIEW\\tminimap2-or-MCScanX-handoff\\t${meta.reference_build}\\tREQUIRED\\tREQUIRED\\tSynteny is collinearity evidence and must not be conflated with orthology or function\\n' >> ${meta.sample}.synteny.tsv
    """

    stub:
    """
    printf 'sample\\tsynteny_status\\tmethod\\treference_build\\tanchor_status\\tblock_status\\tnote\\n' > ${meta.sample}.synteny.tsv
    printf '${meta.sample}\\tSTUB\\tSTUB\\t${meta.reference_build}\\tSTUB\\tSTUB\\tSynthetic wiring only; no synteny inference or evolutionary claim\\n' >> ${meta.sample}.synteny.tsv
    """
}
