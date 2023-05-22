#!/bin/bash
#usage: $ bash ThisScript.sh /PATH/to/input/dir/ /PATH/to/output/dir/
#1) PREPARE ENVIRONMENT
inputDir=$1
timeStamp=$(date +"%Y%m%d.%H%M")
outDir=${2}Cutadapt_${timeStamp}
mkdir $outDir
cd $outDir
#2) CHOOSE DATA AND PRINT PBS SCRIPT
for file in "${1}"*1.fastq.gz #koncovka dat, pripadne uprav; napr. /storage/folder/jani/Nfur_f01_1.fastq.gz
do
	fileName="$(basename "$file" _1.fastq.gz)" #identifikator datasetu napr. Nfur_f01
	baseName="$(basename "$file")" #dataset napr. Nfur_f01_1.fastq.gz (bez cesty do moji slozky)
	scriptName=${outDir}/PBS_Cutadapt_"${fileName}".sh
	(
	cat << endOfPBSscript
#!/bin/bash
#PBS -N Cutadapt
#PBS -l select=1:ncpus=6:mem=32gb:scratch_local=100gb
#PBS -l walltime=4:00:00

trap 'clean_scratch' TERM EXIT

cd \${SCRATCHDIR}

scp ${file} \${SCRATCHDIR} || exit 1
scp ${1}${fileName}_2.fastq.gz \${SCRATCHDIR} || exit 1

module add python27-modules-gcc

cutadapt --nextseq-trim=20 \
-m 100 -M 100 \
--length 100 \
-a AATGATACGGCGACCACCGAGATCTACACTCTTTCCCTACACGACGCTCTTCCGATCT \
-A GATCGGAAGAGCACACGTCTGAACTCCAGTCACNNNNNNATCTCGTATGCCGTCTTCTGCTTG \
-o ${fileName}_cut_1.fastq.gz \
-p ${fileName}_cut_2.fastq.gz \
${baseName} ${fileName}_2.fastq.gz


rm \${SCRATCHDIR}/${baseName}
rm \${SCRATCHDIR}/${fileName}_2.fastq.gz

scp -r \${SCRATCHDIR}/* ${outDir} || export CLEAN_SCRATCH=true

endOfPBSscript

	) > ${scriptName}
	chmod +x ${scriptName}
	qsub ${scriptName}
done
