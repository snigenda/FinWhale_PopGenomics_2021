#!/bin/bash

# Title: qsub wrapper for WGSproc5 Joint Genotyping
#
# Author: Meixi Lin
# Date: Thu Jan 30 12:20:44 2020

QSUB=/u/systems/UGE8.6.4/bin/lx-amd64/qsub
HOMEDIR=<homedir2>/finwhale
WORKSCRIPT=${HOMEDIR}/scripts/WGSproc6/WGSproc6_TrimAlternates_VariantAnnotator_20200510.sh
HARD_RESOURCE="h_rt=23:00:00,h_data=23G"

USER=${1} ## "meixilin"/"snigenda"
REF=${2} # should be Minke all the time but for compatibility of the 6 individuals

if [ $REF == 'Minke' ]; then
    NJOBS=96
fi
if [ $REF == 'Bryde' ]; then
    NJOBS=23
fi

${QSUB} -t 1-${NJOBS} -l ${HARD_RESOURCE} ${WORKSCRIPT} ${USER} ${REF}

echo "The qsub script was"
echo "${QSUB} -t 1-${NJOBS} -l ${HARD_RESOURCE} ${WORKSCRIPT} ${USER} ${REF}"
