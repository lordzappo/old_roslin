#!/usr/bin/env cwl-runner

$namespaces:
  dct: http://purl.org/dc/terms/
  foaf: http://xmlns.com/foaf/0.1/
  doap: http://usefulinc.com/ns/doap#

$schemas:
- http://dublincore.org/2012/06/14/dcterms.rdf
- http://xmlns.com/foaf/spec/20140114.rdf
- http://usefulinc.com/ns/doap#

doap:release:
- class: doap:Version
  doap:name: module-5
  doap:revision: 1.0.0
- class: doap:Version
  doap:name: cwl-wrapper
  doap:revision: 1.0.0

dct:creator:
- class: foaf:Organization
  foaf:name: Memorial Sloan Kettering Cancer Center
  foaf:member:
  - class: foaf:Person
    foaf:name: Jaeyoung Chun
    foaf:mbox: mailto:chunj@mskcc.org

dct:contributor:
- class: foaf:Organization
  foaf:name: Memorial Sloan Kettering Cancer Center
  foaf:member:
  - class: foaf:Person
    foaf:name: Christopher Harris
    foaf:mbox: mailto:harrisc2@mskcc.org
  - class: foaf:Person
    foaf:name: Ronak H. Shah
    foaf:mbox: mailto:shahr2@mskcc.org
  - class: foaf:Person
    foaf:name: Jaeyoung Chun
    foaf:mbox: mailto:chunj@mskcc.org

cwlVersion: v1.0

class: Workflow
requirements:
  MultipleInputFeatureRequirement: {}
  ScatterFeatureRequirement: {}
  SubworkflowFeatureRequirement: {}
  InlineJavascriptRequirement: {}
  StepInputExpressionRequirement: {}

inputs:

  bams:
    type:
      type: array
      items: File
    secondaryFiles: .bai
  genome: string
  bait_intervals: File
  target_intervals: File
  fp_intervals: File

outputs:

  as_metrics:
    type: File
    outputSource: scatter_metrics/as_metrics_files
  hs_metrics:
    type: File
    outputSource: scatter_metrics/hs_metrics_files
  insert_metrics:
    type: File
    outputSource: scatter_metrics/is_metrics
  insert_pdf:
    type: File
    outputSource: scatter_metrics/is_hist
  per_target_coverage:
    type: File
    outputSource: scatter_metrics/per_target_coverage
  qual_metrics:
    type: File
    outputSource: scatter_metrics/qual_metrics
  qual_pdf:
    type: File
    outputSource: scatter_metrics/qual_pdf
  doc_basecounts:
    type: File
    outputSource: scatter_metrics/doc_basecounts

steps:

  scatter_metrics:
    in:
      bam: bams
      genome: genome
      bait_intervals: bait_intervals
      target_intervals: target_intervals
      fp_intervals: fp_intervals
    out: [as_metrics_files, hs_metrics_files, is_metrics, per_target_coverage, qual_metrics, qual_pdf, is_hist, doc_basecounts]
    scatter: [bam]
    scatterMethod: dotproduct
    run:
      class: Workflow
      inputs:
        bam: File
        genome: string
        bait_intervals: File
        target_intervals: File
        fp_intervals: File
      outputs:
        as_metrics_files:
          type: File
          outputSource: as_metrics/out_file
        hs_metrics_files:
          type: File
          outputSource: hs_metrics/out_file
        per_target_coverage:
          type: File
          outputSource: hs_metrics/per_target_out
        is_metrics:
          type: File
          outputSource: insert_metrics/is_file
        is_hist:
          type: File
          outputSource: insert_metrics/is_hist
        qual_metrics:
          type: File
          outputSource: quality_metrics/qual_file
        qual_pdf:
          type: File
          outputSource: quality_metrics/qual_hist
        doc_basecounts:
          type: File
          outputSource: doc/out_file

      steps:
        as_metrics:
          run: cmo-picard.CollectAlignmentSummaryMetrics/1.96/cmo-picard.CollectAlignmentSummaryMetrics.cwl
          in:
            I: bam
            O:
              valueFrom: ${ return inputs.I.basename.replace(".bam", ".asmetrics")}
            LEVEL:
              valueFrom: ${return ["null", "SAMPLE"]}
          out: [out_file]

        hs_metrics:
          run: cmo-picard.CalculateHsMetrics/1.96/cmo-picard.CalculateHsMetrics.cwl
          in:
            BI: bait_intervals
            TI: target_intervals
            I: bam
            R: genome
            O:
              valueFrom: ${ return inputs.I.basename.replace(".bam", ".hsmetrics")}
            PER_TARGET_COVERAGE:
              valueFrom: ${ return inputs.I.basename.replace(".bam", ".per_target.hsmetrics")}
          out: [out_file, per_target_out]
        insert_metrics:
          run: cmo-picard.CollectMultipleMetrics/1.96/cmo-picard.CollectMultipleMetrics.cwl
          in:
            I: bam
            PROGRAM:
              valueFrom: ${return ["null", "CollectInsertSizeMetrics"]}
            O:
              valueFrom: ${ return inputs.I.basename.replace(".bam", ".ismetrics")}
          out: [ is_file, is_hist]
        quality_metrics:
          run: cmo-picard.CollectMultipleMetrics/1.96/cmo-picard.CollectMultipleMetrics.cwl
          in:
            I: bam
            PROGRAM:
              valueFrom: ${return ["null","MeanQualityByCycle"]}
            O:
              valueFrom: ${ return inputs.I.basename.replace(".bam", ".qmetrics")}
          out: [qual_file, qual_hist]
        doc:
          run: cmo-gatk.DepthOfCoverage/3.3-0/cmo-gatk.DepthOfCoverage.cwl
          in:
            input_file: bam
            intervals: fp_intervals
            reference_sequence: genome
            out:
              valueFrom: ${ return inputs.input_file.basename.replace(".bam", "_FP_base_counts.txt") }
            omitLocustable:
              valueFrom: ${ return true; }
            omitPerSampleStats:
              valueFrom: ${ return true; }
            minMappingQuality:
              valueFrom: ${ return "10"; }
            minBaseQuality:
              valueFrom: ${ return "3"; }
            omitIntervals:
              valueFrom: ${ return true; }
            printBaseCounts:
              valueFrom: ${ return true; }
          out: [out_file]