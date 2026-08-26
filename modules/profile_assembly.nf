process PROFILE_ASSEMBLY {
    tag "${meta.sample}"
    publishDir "${params.outdir}/01_assembly", mode: 'copy'

    input:
    tuple val(meta), path(assembly)

    output:
    tuple val(meta), path("${meta.sample}.assembly-profile.tsv"), emit: profile

    script:
    """
    checksum=\$(sha256sum ${assembly} | cut -d' ' -f1)
    contigs=\$(grep -c '^>' ${assembly} || true)
    bases=\$(awk '!/^>/ {gsub(/[[:space:]]/, ""); total += length(\$0)} END {print total + 0}' ${assembly})
    printf 'sample\\tassembly_status\\tassembly_sha256\\tcontigs\\tbases\\tnote\\n' > ${meta.sample}.assembly-profile.tsv
    printf '${meta.sample}\\tAVAILABLE\\t%s\\t%s\\t%s\\tProfile is a provenance gate, not a completeness claim\\n' "\$checksum" "\$contigs" "\$bases" >> ${meta.sample}.assembly-profile.tsv
    """

    stub:
    """
    printf 'sample\\tassembly_status\\tassembly_sha256\\tcontigs\\tbases\\tnote\\n' > ${meta.sample}.assembly-profile.tsv
    printf '${meta.sample}\\tSTUB\\tSTUB\\tSTUB\\tSTUB\\tSynthetic wiring only; no assembly-quality claim\\n' >> ${meta.sample}.assembly-profile.tsv
    """
}
