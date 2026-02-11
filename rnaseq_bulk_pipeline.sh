#!/bin/bash
# ===============================================================
#  SLURM Batch Script: Bulk RNA-seq Analysis Pipeline
# ===============================================================
#
# Description:
# High performance computing compatible RNA-seq pipeline for
# paired-end bulk sequencing data. Designed for SLURM clusters.
#
# Workflow:
#   1. Raw read quality control (FastQC)
#   2. Adapter and quality trimming (Trim Galore)
#   3. Optional post-trimming QC
#   4. Optional Salmon transcriptome indexing
#   5. Transcript abundance quantification (Salmon)
#
# ===============================================================

#SBATCH --job-name=rnaseq_bulk_pipeline
#SBATCH --time=05:00:00
#SBATCH --partition=bigmem
#SBATCH -A <project_account>
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=48
#SBATCH --mem=0
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=<your_email>

# ===============================================================
#   Load Environment
# ===============================================================

module load anaconda
conda activate salmonenv

# ===============================================================
#   Define Input / Output Paths
#   (Modify these before running)
# ===============================================================

RAW_DIR="/path/to/raw_fastq"
TRIMMED_DIR="/path/to/trimmed_fastq"
FASTQC_RAW_DIR="/path/to/fastqc_raw"
FASTQC_TRIMMED_DIR="/path/to/fastqc_trimmed"
QUANT_DIR="/path/to/quant"
INDEX_DIR="/path/to/transcript_index"

# Create output directories
mkdir -p "$TRIMMED_DIR" \
         "$FASTQC_RAW_DIR" \
         "$FASTQC_TRIMMED_DIR" \
         "$QUANT_DIR" \
         logs

# ===============================================================
# STEP 1: Quality Control on Raw FASTQ Files
# ===============================================================

echo "Running FastQC on raw FASTQ files..."
cd "$RAW_DIR"

for fq in *.fastq.gz; do
    fastqc "$fq" -o "$FASTQC_RAW_DIR"
done

echo "Step 1 complete: Raw QC finished."

# ===============================================================
# STEP 2: Adapter and Quality Trimming
# ===============================================================

echo "Running Trim Galore..."
cd "$RAW_DIR"

for fq1 in *_1.fastq.gz; do
    base=$(basename "$fq1" _1.fastq.gz)
    fq2="${base}_2.fastq.gz"

    trim_galore --paired \
                --cores $SLURM_CPUS_PER_TASK \
                "$fq1" "$fq2" \
                -o "$TRIMMED_DIR"
done

echo "Step 2 complete: Trimming finished."

# ===============================================================
# STEP 3: Optional Post-Trim Quality Control
# ===============================================================
# Uncomment if post-trimming QC is required

# echo "Running FastQC on trimmed reads..."
# cd "$TRIMMED_DIR"
# for fq in *_val_*.fq.gz; do
#     fastqc "$fq" -o "$FASTQC_TRIMMED_DIR"
# done
# echo "Step 3 complete: Post-trim QC finished."

# ===============================================================
# STEP 4: Optional Salmon Indexing (Run Once)
# ===============================================================
# Uncomment if index needs to be built

# FASTA="/path/to/reference_transcripts.fa"
# echo "Building Salmon index..."
# salmon index -t "$FASTA" \
#              -i "$INDEX_DIR" \
#              --gencode \
#              --threads $SLURM_CPUS_PER_TASK
# echo "Step 4 complete: Index built."

# ===============================================================
# STEP 5: Salmon Quantification
# ===============================================================

echo "Starting Salmon quantification..."
cd "$TRIMMED_DIR"

for fq1 in *_1_val_1.fq.gz; do
    base=$(basename "$fq1" _1_val_1.fq.gz)
    fq2="${base}_2_val_2.fq.gz"

    echo "Processing sample: $base"

    salmon quant -i "$INDEX_DIR" \
                 --libType A \
                 -1 "$fq1" \
                 -2 "$fq2" \
                 --validateMappings \
                 -p $SLURM_CPUS_PER_TASK \
                 -o "$QUANT_DIR/$base"
done

echo "Step 5 complete: Quantification finished."

conda deactivate

echo "Pipeline completed successfully."
