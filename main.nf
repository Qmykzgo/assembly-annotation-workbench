nextflow.enable.dsl=2

include { PROFILE_ASSEMBLY } from './modules/profile_assembly'
include { ANNOTATE_GENES } from './modules/annotate_genes'
include { SUMMARIZE_ANNOTATION } from './modules/summarize_annotation'
include { COMPARE_ORTHOLOGY } from './modules/compare_orthology'
include { COMPARE_SYNTENY } from './modules/compare_synteny'
include { ASSESS_ANNOTATION_QUALITY } from './modules/assess_annotation_quality'
include { ASSESS_RELEASE } from './modules/assess_release'
include { COLLECT_REPORT } from './modules/collect_report'
include { WRITE_PROVENANCE } from './modules/provenance'

params.input = params.input ?: 'assets/test-data/annotation.csv'
params.outdir = params.outdir ?: 'results/assembly-annotation'
params.mode = params.mode ?: 'real'

workflow {
    if (!file(params.input).exists()) {
        error "Input manifest not found: ${params.input}"
    }

    samplesheet = Channel.fromPath(params.input, checkIfExists: true)
    rows = samplesheet.splitCsv(header: true)

    inputs = rows.map { row ->
        def sample = row.sample?.toString()?.trim()
        def assembly = row.assembly_fasta?.toString()?.trim()
        def reference = row.reference_fasta?.toString()?.trim()
        def meta = [
            sample: sample,
            organism: row.organism?.toString()?.trim() ?: 'not_declared',
            annotation_mode: row.annotation_mode?.toString()?.trim() ?: 'not_declared',
            database_release: row.database_release?.toString()?.trim() ?: 'not_declared',
            reference_build: row.reference_build?.toString()?.trim() ?: 'not_declared',
            comparison_group: row.comparison_group?.toString()?.trim() ?: 'not_declared'
        ]
        if (!sample || !assembly || !reference) {
            error "Each manifest row requires sample, assembly_fasta, and reference_fasta"
        }
        tuple(meta, file(assembly), file(reference))
    }

    profile = PROFILE_ASSEMBLY(inputs.map { meta, assembly, reference -> tuple(meta, assembly) })
    annotation = ANNOTATE_GENES(inputs.map { meta, assembly, reference -> tuple(meta, assembly) })
    annotation_quality = SUMMARIZE_ANNOTATION(annotation.annotation)
    orthology = COMPARE_ORTHOLOGY(annotation.annotation)
    synteny = COMPARE_SYNTENY(inputs.map { meta, assembly, reference -> tuple(meta, assembly, reference) })

    quality_input = profile.profile
        .combine(annotation_quality.annotation_quality, by: 0)
        .map { joined -> tuple(joined[0], joined[1], joined[2]) }
    quality = ASSESS_ANNOTATION_QUALITY(quality_input)

    release_input = annotation.annotation
        .combine(orthology.orthology, by: 0)
        .map { joined -> tuple(joined[0], joined[1], joined[2]) }
        .combine(synteny.synteny, by: 0)
        .map { joined -> tuple(joined[0], joined[1], joined[2], joined[3]) }
        .combine(quality.quality, by: 0)
        .map { joined -> tuple(joined[0], joined[1], joined[2], joined[3], joined[4]) }
    release = ASSESS_RELEASE(release_input)

    COLLECT_REPORT(release.release.collect())
    WRITE_PROVENANCE(samplesheet)
}
