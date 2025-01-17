#!/bin/bash
#$ -wd <homedir2>/finwhale
#$ -l h_rt=120:00:00,h_data=6G,highp
#$ -o <homedir2>/finwhale/reports/WGSproc0.out.txt
#$ -e <homedir2>/finwhale/reports/WGSproc0.err.txt
#$ -pe shared 8
#$ -m abe

# reference: https://gatkforums.broadinstitute.org/gatk/discussion/2798/howto-prepare-a-reference-for-use-with-bwa-and-gatk

echo `date` "prep refseq for minke"

conda activate gentools

# define variables
HOMEDIR=<homedir2>/finwhale
WORK=${HOMEDIR}/cetacean_genomes/minke_whale_genome/GCF_000493695.1_BalAcu1.0
AR_REFERENCE_SEQ=GCF_000493695.1_BalAcu1.0_genomic.fna.gz # to archive
REFERENCE_SEQ=GCF_000493695.1_BalAcu1.0_genomic.fasta

# gunzip file
cd $WORK
cp ${AR_REFERENCE_SEQ} ${AR_REFERENCE_SEQ/.fna.gz/.fasta.gz}
gunzip ${AR_REFERENCE_SEQ/.fna.gz/.fasta.gz}

# generate index for reference sequence
bwa index ${REFERENCE_SEQ}

samtools faidx ${REFERENCE_SEQ}

# generate dictionary (step 4c)
picard -Xmx40G CreateSequenceDictionary \
REFERENCE=${REFERENCE_SEQ} \
OUTPUT=${REFERENCE_SEQ/fasta/dict}

conda deactivate
echo `date` "done prep refseq for minke"