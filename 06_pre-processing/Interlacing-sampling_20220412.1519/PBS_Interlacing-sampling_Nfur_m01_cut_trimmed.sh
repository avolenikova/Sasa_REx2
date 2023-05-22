#!/bin/bash
#PBS -N Interl-sampl
#PBS -l select=1:ncpus=16:mem=32gb:scratch_local=150gb
#PBS -l walltime=3:00:00
#PBS -o /storage/pruhonice1-ibot/home/volen_a/jani/06_pre-processing/Interlacing-sampling_20220412.1519/Nfur_m01_cut_trimmed_Interl-sampl.stdout
#PBS -e /storage/pruhonice1-ibot/home/volen_a/jani/06_pre-processing/Interlacing-sampling_20220412.1519/Nfur_m01_cut_trimmed_Interl-sampl.stderr

trap 'clean_scratch' TERM EXIT

cd ${SCRATCHDIR}

#copy input files to scratchdir
scp /storage/pruhonice1-ibot/home/volen_a/jani/04_Trimmomatic/Trimmomatic_20220411.1157/Nfur_m01_cut_trimmed_1P.fastq.gz ${SCRATCHDIR}
scp /storage/pruhonice1-ibot/home/volen_a/jani/04_Trimmomatic/Trimmomatic_20220411.1157/Nfur_m01_cut_trimmed_2P.fastq.gz ${SCRATCHDIR}

#conversion to fasta
zcat /storage/pruhonice1-ibot/home/volen_a/jani/04_Trimmomatic/Trimmomatic_20220411.1157/Nfur_m01_cut_trimmed_1P.fastq.gz | sed -n '1~4s/^@/>/p;2~4p' > Nfur_m01_cut_trimmed_1P.fasta
zcat Nfur_m01_cut_trimmed_2P.fastq.gz | sed -n '1~4s/^@/>/p;2~4p' > Nfur_m01_cut_trimmed_2P.fasta

#adding suffix to forward and reverse reads
#for f in Nfur_m01_cut_trimmed_1P.fasta;
#do
#awk -F " " '{if (/^>/) print $1 "/1"; else print $0}' >>Nfur_m01_cut_trimmed_rnmd_1P.fasta;
#done
#
#for f in Nfur_m01_cut_trimmed_2P.fasta;
#do
#awk -F " " '{if (/^>/) print $1 "/2"; else print $0}' >>Nfur_m01_cut_trimmed_rnmd_2P.fasta;
#done

#loading tools
module add repeatexplorerREportal
module unload python-2.7.10-gcc
module add python-2.7.5
module add debian8-compat

#interlacing
fasta_interlacer.py -a Nfur_m01_cut_trimmed_1P.fasta -b Nfur_m01_cut_trimmed_2P.fasta -p Nfur_m01_cut_trimmed_interlaced.fasta -x Nfur_m01_cut_trimmed_notInterlaced.fasta

#sampling (1 technica replicas)
sampleFasta.sh -f Nfur_m01_cut_trimmed_interlaced.fasta -s 123 -n 500 -p true > Nfur_m01_cut_trimmed_subs-500reads.fasta
#sed 's/>/>1/g' Nfur_m01_cut_trimmed_subs-500k_r1.fasta > Nfur_m01_cut_trimmed_subs-500k_pref_r1.fasta

#sampleFasta.sh #-f Nfur_m01_cut_trimmed_interlaced.fasta #-s 321456 #-n 500000 #-p true #> Nfur_m01_cut_trimmed_subs-500k_r2.fasta
#sed 's/>/>2/g' Nfur_m01_cut_trimmed_subs-500k_r2.fasta > Nfur_m01_cut_trimmed_subs-500k_pref_r2.fasta

#sampleFasta.sh #-f Nfur_m01_cut_trimmed_interlaced.fasta #-s 321654 #-n 500000 #-p true #> Nfur_m01_cut_trimmed_subs-500k_r3.fasta
#sed 's/>/>3/g' Nfur_m01_cut_trimmed_subs-500k_r3.fasta > Nfur_m01_cut_trimmed_subs-500k_pref_r3.fasta

#concatenating
#cat #Nfur_m01_cut_trimmed_subs-500k_pref_r1.fasta #Nfur_m01_cut_trimmed_subs-500k_pref_r2.fasta #Nfur_m01_cut_trimmed_subs-500k_pref_r3.fasta #>> Nfur_m01_cut_trimmed_REx2_500k-each.fasta

#removing input files
rm ${SCRATCHDIR}/Nfur_m01_cut_trimmed_1P.fastq.gz
rm ${SCRATCHDIR}/Nfur_m01_cut_trimmed_2P.fastq.gz

#moving outputs to outdir
scp -r ${SCRATCHDIR}/* /storage/pruhonice1-ibot/home/volen_a/jani/06_pre-processing/Interlacing-sampling_20220412.1519 || export CLEAN_SCRATCH=true

