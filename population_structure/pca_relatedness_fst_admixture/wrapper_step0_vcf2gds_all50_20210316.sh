#!/bin/bash
#$ -l h_data=24G,h_vmem=40G,h_rt=23:59:00
#$ -wd <homedir>
#$ -o <homedir>/reports/PopStructure/step0_vcf2gds_all50_20210316.out.txt
#$ -e <homedir>/reports/PopStructure/step0_vcf2gds_all50_20210316.err.txt
#$ -m abe

# @version 		v0
# @usage		qsub wrapper_step0_vcf2gds_all50_20210316.sh
# @description	Wrapper to submit the Rscript
# Author: Meixi Lin
# Date: Tue Feb 23 21:42:19 2021

############################################################
## import packages


conda activate gentools

set -eo pipefail

############################################################
## def functions

############################################################
## def variables
DATASET='all50'
REF='Minke'

HOMEDIR=<homedir>
WORKDIR=${HOMEDIR}/PopStructure/${DATASET}/${REF}

WORKSCRIPT=${HOMEDIR}/scripts/PopStructure/all50/step0_vcf2gds_all50_20210316.R
COMMITID=$(git --git-dir="${HOMEDIR}/scripts/.git" --work-tree="${HOMEDIR}/scripts" rev-parse master)

# The input files
VCFDIR=<homedir2>/finwhale/filteredvcf/${DATASET}/${REF}
VCFPREFIX=JointCalls_${DATASET}_08_B_VariantFiltration

############################################################
## main

mkdir -p ${WORKDIR}
cd ${WORKDIR}

echo -e "[$(date "+%Y-%m-%d %T")] JOB ID ${JOB_ID}; GIT commit id ${COMMITID}"

Rscript --vanilla ${WORKSCRIPT} ${VCFDIR} ${VCFPREFIX} ${WORKDIR}
exitVal=${?}
if [ ${exitVal} -ne 0 ]; then
    echo -e "[$(date "+%Y-%m-%d %T")] FAIL"
    exit 1
fi
echo -e "[$(date "+%Y-%m-%d %T")] Done"

conda deactivate