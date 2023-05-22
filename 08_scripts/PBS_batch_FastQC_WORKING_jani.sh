#!/bin/bash
#usage: $ bash ThisScript.sh /PATH/to/input/dir/ /PATH/to/output/dir/
#1) PREPARE ENVIRONMENT
inputDir=$1
timeStamp=$(date +"%Y%m%d.%H%M")
outDir=${2}FastQC_${timeStamp}
mkdir $outDir
cd $outDir
#2) CHOOSE DATA AND PRINT PBS SCRIPT
for file in "${1}"*.fastq.gz
do
	fileName="$(basename "$file" .fastq.gz)"
	baseName="$(basename "$file")"
	scriptName=${outDir}/FastQC_"${fileName}".pbs
	(
	cat << endOfPBSscript
#!/bin/bash
#PBS -N FastQC
#PBS -l select=1:ncpus=4:mem=8gb:scratch_local=100gb
#PBS -l walltime=2:00:00

trap 'clean_scratch' TERM EXIT

cd \${SCRATCHDIR}

scp ${file} \${SCRATCHDIR}

module add fastQC-0.11.5

fastqc ${baseName}

rm \${SCRATCHDIR}/${baseName}

scp \${SCRATCHDIR}/*.html ${outDir} || export CLEAN_SCRATCH=true

endOfPBSscript

	) > ${scriptName}
	chmod +x ${scriptName}
	qsub ${scriptName}
done
