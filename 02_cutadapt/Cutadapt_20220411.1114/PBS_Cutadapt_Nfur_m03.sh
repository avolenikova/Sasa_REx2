#!/bin/bash
#PBS -N Cutadapt
#PBS -l select=1:ncpus=6:mem=32gb:scratch_local=100gb
#PBS -l walltime=4:00:00

trap 'clean_scratch' TERM EXIT

cd ${SCRATCHDIR}

scp /storage/pruhonice1-ibot/home/volen_a/jani/00_rawData/Nfur_m03_1.fastq.gz ${SCRATCHDIR} || exit 1
scp /storage/pruhonice1-ibot/home/volen_a/jani/00_rawData/Nfur_m03_2.fastq.gz ${SCRATCHDIR} || exit 1

module add python27-modules-gcc

cutadapt --nextseq-trim=20 -m 100 -M 100 --length 100 -a AATGATACGGCGACCACCGAGATCTACACTCTTTCCCTACACGACGCTCTTCCGATCT -A GATCGGAAGAGCACACGTCTGAACTCCAGTCACNNNNNNATCTCGTATGCCGTCTTCTGCTTG -o Nfur_m03_cut_1.fastq.gz -p Nfur_m03_cut_2.fastq.gz Nfur_m03_1.fastq.gz Nfur_m03_2.fastq.gz


rm ${SCRATCHDIR}/Nfur_m03_1.fastq.gz
rm ${SCRATCHDIR}/Nfur_m03_2.fastq.gz

scp -r ${SCRATCHDIR}/* /storage/pruhonice1-ibot/home/volen_a/jani/02_cutadapt/Cutadapt_20220411.1114 || export CLEAN_SCRATCH=true

