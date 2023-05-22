#!/bin/bash
#PBS -N Trimmomatic
#PBS -l select=1:ncpus=16:mem=32gb:scratch_local=100gb
#PBS -l walltime=2:00:00
#PBS -o /storage/pruhonice1-ibot/home/volen_a/jani/04_Trimmomatic/Trimmomatic_20220411.1157/Nfur_f03_cut_Trimmomatic.stdout
#PBS -e /storage/pruhonice1-ibot/home/volen_a/jani/04_Trimmomatic/Trimmomatic_20220411.1157/Nfur_f03_cut_Trimmomatic.stderr

trap 'clean_scratch' TERM EXIT

cd ${SCRATCHDIR}

scp /storage/pruhonice1-ibot/home/volen_a/jani/02_cutadapt/Cutadapt_20220411.1114/Nfur_f03_cut_1.fastq.gz ${SCRATCHDIR}
scp /storage/pruhonice1-ibot/home/volen_a/jani/02_cutadapt/Cutadapt_20220411.1114/Nfur_f03_cut_2.fastq.gz ${SCRATCHDIR}
scp /storage/brno2/home/volen_a/klup/03_trimmomatic/Truseq_PE_frankenstein.fa ${SCRATCHDIR} || exit 1 

module add trimmomatic-0.39

java -jar /software/trimmomatic/0.39/trimmomatic-0.39/Trimmomatic-0.39/trimmomatic-0.39.jar PE -threads 15 -phred33 -trimlog Nfur_f03_cut_trimlog.txt -basein Nfur_f03_cut_1.fastq.gz -baseout Nfur_f03_cut_trimmed.fastq.gz ILLUMINACLIP:./Truseq_PE_frankenstein.fa:2:30:10:1:true SLIDINGWINDOW:5:20 HEADCROP:10 MINLEN:90

rm ${SCRATCHDIR}/Nfur_f03_cut_1.fastq.gz
rm ${SCRATCHDIR}/Nfur_f03_cut_2.fastq.gz

scp -r ${SCRATCHDIR}/* /storage/pruhonice1-ibot/home/volen_a/jani/04_Trimmomatic/Trimmomatic_20220411.1157 || export CLEAN_SCRATCH=true

