process COLLECT_REPORT {
    publishDir params.outdir, mode: 'copy', pattern: 'annotation_comparison_summary.*'

    input:
    path metrics

    output:
    path 'annotation_comparison_summary.tsv', emit: summary_tsv
    path 'annotation_comparison_summary.md', emit: summary_md

    script:
    def metric_args = metrics.collect { it.toString() }.join(' ')
    """
    python3 ${projectDir}/scripts/summarize_annotation.py ${metric_args} --output annotation_comparison_summary.tsv --markdown annotation_comparison_summary.md
    """
}
