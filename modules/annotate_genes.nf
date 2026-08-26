process ANNOTATE_GENES {
    tag "${meta.sample}"
    publishDir "${params.outdir}/02_annotation", mode: 'copy'

    input:
    tuple val(meta), path(assembly)

    output:
    tuple val(meta), path("${meta.sample}.annotation.tsv"), emit: annotation

    script:
    """
    printf 'sample\\tannotation_status\\tfunctional_status\\tannotation_mode\\tannotation_tool\\ttool_version\\tdatabase_release\\tpredicted_features\\tnote\\n' > ${meta.sample}.annotation.tsv
    printf '${meta.sample}\\tREVIEW\\tREVIEW\\t${meta.annotation_mode}\\tProkka-or-Bakta-or-BRAKER-handoff\\tdeclared-by-user\\t${meta.database_release}\\tREQUIRED\\tReal execution must preserve model, database, evidence mode, and partial-feature handling\\n' >> ${meta.sample}.annotation.tsv
    """

    stub:
    """
    printf 'sample\\tannotation_status\\tfunctional_status\\tannotation_mode\\tannotation_tool\\ttool_version\\tdatabase_release\\tpredicted_features\\tnote\\n' > ${meta.sample}.annotation.tsv
    printf '${meta.sample}\\tSTUB\\tSTUB\\t${meta.annotation_mode}\\tSTUB\\tSTUB\\t${meta.database_release}\\tSTUB\\tSynthetic wiring only; no gene prediction or functional claim\\n' >> ${meta.sample}.annotation.tsv
    """
}
