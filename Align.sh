#!/bin/bash

##Run in parallel on one node

#PBS -m abe
#PBS -N STAR1
#PBS -l select=1:ncpus=24:mpiprocs=4
#PBS -P CBBI1195
#PBS -l walltime=48:00:00
#PBS -q smp
#PBS -J 1-103%5
#PBS -o /mnt/lustre/users/yswart/output/alignment.out
#PBS -e /mnt/lustre/users/yswart/output/alignment.err
#PBS -M yolandi01@sun.ac.za


cd /mnt/lustre/users/yswart

module load chpc/BIOMODULES
module load STAR

start=`date +%s`
echo $HOSTNAME
echo "My PBS_ARRAY_ID:" $PBS_ARRAY_ID

sample=$(sed '${PBS_ARRAY_ID}q;d' samples.txt)
REF="References/star.overlap100.gencode.v31"

outpath='02-STAR_alignment'
[[ -d ${outpath} ]] || mkdir ${outpath}
[[ -d ${outpath}/${sample} ]] || mkdir ${outpath}/${sample}

echo "SAMPLE: ${sample}"

module load STAR/2.5.3a


call="STAR
     --runThreadN 8 \
     --genomeDir $REF \
     --outSAMtype BAM SortedByCoordinate \
     --readFilesCommand zcat \
     --readFilesIn 01-HTS_Preproc/${sample}/${sample}_SE.fastq.gz \
     --quantMode GeneCounts \
     --outFileNamePrefix ${outpath}/${sample}/${sample}_ \
     > ${outpath}/${sample}/${sample}-STAR.stdout 2> ${outpath}/${sample}/${sample}-STAR.stderr"

echo $call
eval $call

end=`date +%s`
runtime=$((end-start))
echo $runtime
