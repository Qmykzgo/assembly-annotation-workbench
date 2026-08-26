process ASSESS_RELEASE {
    tag "${meta.sample}"
    publishDir "${params.outdir}/06_reports", mode: 'copy'

    input:
    tuple val(meta), path(annotation), path(orthology), path(synteny), path(quality)

    output:
    path "${meta.sample}.annotation-readiness.tsv", emit: release

    script:
    """
    printf 'sample\\tfeature_scope\\tannotation_status\\tfunctional_status\\torthology_status\\tsynteny_status\\tcompleteness_status\\tfragmentation_status\\tdatabase_release\\trelease_status\\tnote\\n' > ${meta.sample}.annotation-readiness.tsv
    printf '${meta.sample}\\tgene-models\\tREVIEW\\tREVIEW\\tREVIEW\\tREVIEW\\tREVIEW\\tREVIEW\\t${meta.database_release}\\tREVIEW\\tReal execution requires database, model, orthology, synteny, and quality review\\n' >> ${meta.sample}.annotation-readiness.tsv
    """

    stub:
    """
    printf 'sample\\tfeature_scope\\tannotation_status\\tfunctional_status\\torthology_status\\tsynteny_status\\tcompleteness_status\\tfragmentation_status\\tdatabase_release\\trelease_status\\tnote\\n' > ${meta.sample}.annotation-readiness.tsv
    printf '${meta.sample}\\tgene-models\\tSTUB\\tSTUB\\tSTUB\\tSTUB\\tSTUB\\tSTUB\\t${meta.database_release}\\tSTUB\\tSynthetic wiring only; no gene, orthology, synteny, or function claim\\n' >> ${meta.sample}.annotation-readiness.tsv
    """
}
