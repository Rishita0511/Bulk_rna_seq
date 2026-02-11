# Bulk RNA-seq Analysis Pipeline

High performance computing compatible bulk RNA-seq pipeline designed for paired-end sequencing data. Optimized for execution on SLURM-based high performance computing clusters.

## Overview

This pipeline automates preprocessing and transcript quantification for bulk RNA-seq datasets, including quality control, adapter trimming, and transcript abundance estimation using quasi-mapping. It is designed for reproducible large-scale RNA-seq analysis in HPC environments.

## Workflow

1. Quality control of raw FASTQ files using FastQC  
2. Adapter and quality trimming using Trim Galore  
3. Optional post-trimming quality control  
4. Optional transcriptome index construction using Salmon  
5. Transcript abundance quantification using Salmon  

## Tools and Dependencies

- FastQC  
- Trim Galore  
- Salmon  
- SLURM workload manager  
- Conda  

## Execution

Submit the pipeline to a SLURM cluster using:

    sbatch rnaseq_bulk_pipeline_slurm.sh

Before execution, update directory paths and project account settings within the script.

## Input Requirements

- Paired-end FASTQ files following naming convention:
  
      sample_1.fastq.gz
      sample_2.fastq.gz

- Prebuilt Salmon transcript index or reference transcript FASTA file
