process SUMMARIZE_ANNOTATION {
    tag "${meta.sample}"
    publishDir "${params.outdir}/02_annotation", mode: 'copy'

    input:
    tuple val(meta), path(annotation)

    output:
    tuple val(meta), path("${meta.sample}.annotation-quality.tsv"), emit: annotation_quality

    script:
    """
    printf 'sample\\tfunctional_evidence_status\\tpartial_feature_status\\tdatabase_release\\tquality_status\\tnote\\n' > ${meta.sample}.annotation-quality.tsv
    printf '${meta.sample}\\tREVIEW\\tREQUIRED\\t${meta.database_release}\\tREVIEW\\tFunctional labels require accession-level evidence and model/database review\\n' >> ${meta.sample}.annotation-quality.tsv
    """

    stub:
    """
    printf 'sample\\tfunctional_evidence_status\\tpartial_feature_status\\tdatabase_release\\tquality_status\\tnote\\n' > ${meta.sample}.annotation-quality.tsv
    printf '${meta.sample}\\tSTUB\\tSTUB\\t${meta.database_release}\\tSTUB\\tSynthetic wiring only; no annotation-quality claim\\n' >> ${meta.sample}.annotation-quality.tsv
    """
}
