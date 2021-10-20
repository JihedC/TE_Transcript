#! /bin/bash

#SBATCH  --job-name=star_solo
#SBATCH --mail-type=ALL
#SBATCH --mail-user j.chouaref@lumc.nl
#SBATCH -t 1:0:0
#SBATCH --mem=60000

#/path/to/STAR --genomeDir /path/to/genome/dir/ --readFilesIn ...  [...other parameters...] --soloType ... --soloCBwhitelist ...

READS="/exports/humgen/jihed/scTE/pbmc"
INDEX="/exports/humgen/jihed/genomes/genomepy/hg19/star"
module purge
module load genomics/ngs/samtools/1.11/gcc-8.3.1

STAR --genomeDir $INDEX \
    --readFilesIn $READS/subset_pbmc_1k_v3_S1_L001_R2_001.fastq.gz $READS/subset_pbmc_1k_v3_S1_L001_R1_001.fastq.gz \
    --soloUMIlen 12 --soloType CB_UMI_Simple --soloCBwhitelist 3M-february-2018.txt  \
    --outSAMtype BAM SortedByCoordinate \
    --outSAMattributes NH HI nM AS CR UR CB UB \
    --readFilesCommand zcat \
    --outFilterMultimapNmax 100 \
    --winAnchorMultimapNmax 100 \
    --outMultimapperOrder Random \
    --runRNGseed 777 --outSAMmultNmax 1\
    --outFileNamePrefix pbmc_sample1

STAR --genomeDir $INDEX \
    --readFilesIn $READS/subset_pbmc_1k_v3_S1_L002_R2_001.fastq.gz $READS/subset_pbmc_1k_v3_S1_L002_R1_001.fastq.gz \
    --soloUMIlen 12 --soloType CB_UMI_Simple --soloCBwhitelist 3M-february-2018.txt  \
    --outSAMtype BAM SortedByCoordinate \
    --outSAMattributes NH HI nM AS CR UR CB UB \
    --readFilesCommand zcat \
    --outFilterMultimapNmax 100 \
    --winAnchorMultimapNmax 100 \
    --outMultimapperOrder Random \
    --runRNGseed 777 --outSAMmultNmax 1\
    --outFileNamePrefix pbmc_sample2

#For bam file generated by STARsolo etc, the cell barcodes and UMI need to be integrated into the read 'CR:Z' or 'UR:Z' tags as bellow:

# scTE -i Aligned.sortedByCoord.out.bam -o out -x mm10.exclusive.idx --hdf5 True -CB CR -UMI UR

scTE -i pbmc_sample1Aligned.sortedByCoord.out.bam -o pbmc_sample1 -x hg38.exclusive.idx --hdf5 True -CB CR -UMI UR
scTE -i pbmc_sample1Aligned.sortedByCoord.out.bam -o pbmc_sample1 -x hg38.exclusive.idx -CB CR -UMI UR

scTE -i pbmc_sample1Aligned.sortedByCoord.out.bam -o pbmc_sample2 -x hg38.exclusive.idx --hdf5 True -CB CR -UMI UR
scTE -i pbmc_sample1Aligned.sortedByCoord.out.bam -o pbmc_sample2 -x hg38.exclusive.idx -CB CR -UMI UR
