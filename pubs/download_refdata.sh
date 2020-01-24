#!/bin/bash
set -x
set -e

WORKDIR=${HOME}
#WORKDIR=${HOME}/metagenomics-workshop
mkdir -p ${WORKDIR}/deadmice/indexes
pushd ${WORKDIR}/deadmice/indexes

# Host genome, chr1 only
wget ftp://ftp.ncbi.nlm.nih.gov/genomes/refseq/vertebrate_mammalian/Mus_musculus/reference/GCF_000001635.26_GRCm38.p6/GCF_000001635.26_GRCm38.p6_genomic.fna.gz
gunzip GCF_000001635.26_GRCm38.p6_genomic.fna.gz
mv GCF_000001635.26_GRCm38.p6_genomic.fna mouse.fasta
perl -ne 'print if 1../^>NT_166280\.1/' mouse.fasta|grep -v "NNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNN"|head -n -1 > mouse_chr1.fasta
rm mouse.fasta
bwa index mouse_chr1.fasta

# PhiX 174
wget ftp://ftp.ncbi.nlm.nih.gov/genomes/refseq/viral/Enterobacteria_phage_phiX174_sensu_lato/latest_assembly_versions/GCF_000819615.1_ViralProj14015/GCF_000819615.1_ViralProj14015_genomic.fna.gz
gunzip GCF_000819615.1_ViralProj14015_genomic.fna.gz
mv GCF_000819615.1_ViralProj14015_genomic.fna phix174.fasta
bwa index phix174.fasta

# Genomes for read mapping
mkdir -p genomes
pushd genomes

## Fungi
wget ftp://ftp.ncbi.nlm.nih.gov/genomes/refseq/fungi/Candida_albicans/representative/GCF_000182965.3_ASM18296v3/GCF_000182965.3_ASM18296v3_genomic.fna.gz
gunzip GCF_000182965.3_ASM18296v3_genomic.fna.gz
mv GCF_000182965.3_ASM18296v3_genomic.fna candida_albicans.fasta

wget ftp://ftp.ncbi.nlm.nih.gov/genomes/refseq/fungi/Saccharomyces_cerevisiae/reference/GCF_000146045.2_R64/GCF_000146045.2_R64_genomic.fna.gz
gunzip GCF_000146045.2_R64_genomic.fna.gz
mv GCF_000146045.2_R64_genomic.fna saccharomyces_cerevisiae.fasta

## Bacteria
### Segmented Filamentous Bacteria
wget ftp://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/709/435/GCF_000709435.1_ASM70943v1/GCF_000709435.1_ASM70943v1_genomic.fna.gz
gunzip GCF_000709435.1_ASM70943v1_genomic.fna.gz
mv GCF_000709435.1_ASM70943v1_genomic.fna sfb.fasta

### S24-7 bacteria M1
wget ftp://ftp.ncbi.nlm.nih.gov/genomes/all/GCA/001/689/425/GCA_001689425.1_ASM168942v1/GCA_001689425.1_ASM168942v1_genomic.fna.gz
gunzip GCA_001689425.1_ASM168942v1_genomic.fna.gz
mv GCA_001689425.1_ASM168942v1_genomic.fna s24-7_m1.fasta

popd ## genomes, back in deadmice/indexes/

# MiniKraken
wget https://ccb.jhu.edu/software/kraken/dl/minikraken_20171101_8GB_dustmasked.tgz
tar xvzf minikraken_20171101_8GB_dustmasked.tgz
mv minikraken_20171101_8GB_dustmasked mindb

# CARD
mkdir card
pushd card
wget https://card.mcmaster.ca/download/0/broadstreet-v1.2.1.tar.bz2
tar xvjf broadstreet-v1.2.1.tar.bz2
makeblastdb -dbtype nucl -in nucleotide_fasta_protein_homolog_model.fasta
popd ## card, back in deadmice/indexes/

cat << EOF > ${WORKDIR}/sunbeam-master/deadmice-config.yml
# Sunbeam configuration file
#
# Paths:
#   Paths are resolved through the following rules:
#     1. If the path is absolute, the path is parsed as-is
#     2. If the path is not absolute, the path at 'root' is appended to it
#     3. If the path is not 'output_fp', the path is checked to ensure it exists
#
# Suffixes:
#   Each subsection contains a 'suffix' key that defines the folder under
#   'output_fp' where the results of that section are put.
#

# General options
all:
  root: "${WORKDIR}/deadmice/"
  data_fp: "data_files"
  output_fp: "sunbeam_output"
  filename_fmt: "{sample}_{rp}.fastq"
  subcores: 4
  exclude: []


# Quality control
qc:
  suffix: qc
  # Trimmomatic
  threads: 4
  java_heapsize: 512M
  leading: 3
  trailing: 3
  slidingwindow: [4,15]
  minlen: 36
  adapter_fp: "${WORKDIR}/miniconda3/envs/sunbeam/share/trimmomatic/adapters/NexteraPE-PE.fa"
  # Cutadapt
  fwd_adapters: ['GTTTCCCAGTCACGATC', 'GTTTCCCAGTCACGATCNNNNNNNNNGTTTCCCAGTCACGATC']
  rev_adapters: ['GTTTCCCAGTCACGATC', 'GTTTCCCAGTCACGATCNNNNNNNNNGTTTCCCAGTCACGATC']
  # Decontam.py
  pct_id: 0.5
  frac: 0.6
  keep_sam: False
  method: bwa
  human_genome_fp: "indexes/mouse_chr1.fasta"
  phix_genome_fp: "indexes/phix174.fasta"


# Taxonomic classifications
classify:
  suffix: classify
  threads: 4
  kraken_db_fp: "indexes/mindb"
  taxa_db_fp: ""


# Contig assembly
assembly:
  suffix: assembly
  min_length: 300
  threads: 4
  cap3_fp: "${WORKDIR}/sunbeam-master/local/CAP3"


# Contig annotation
annotation:
  suffix: annotation
  min_contig_len: 500
  circular_kmin: 10
  circular_kmax: 1000
  circular_min_len: 3500


# Blast databases
blast:
  threads: 4

blastdbs:
  root_fp: "indexes/"
  nucleotide:
    card:
      card/nucleotide_fasta_protein_homolog_model.fasta


mapping:
  suffix: mapping
  genomes_fp: ""
  igv_fp: "${WORKDIR}/sunbeam-master/local/IGV/igv"
  threads: 4
  keep_unaligned: False
  igv_prefs:
    # Smooth rendered text.  By default it looks jagged.
    ENABLE_ANTIALIASING: true
    # The pixel width of the left panel that shows the name of the input files.
    # The default is a bit too narrow and will truncate long filenames.
    NAME_PANEL_WIDTH: 360
    # The alignment window size, in kb, below which alignments will become
    # visible.  We don't want to ever require zooming so we will set it to a
    # high value.
    SAM.MAX_VISIBLE_RANGE: 1000
EOF

popd
