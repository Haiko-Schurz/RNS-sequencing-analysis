#!/bin/bash

## assumes htstream is available on the Path

#PBS -m abe
#PBS -N preprocessing
#PBS -l select=1:ncpus=24:mpiprocs=4
#PBS -P CBBI1195
#PBS -l walltime=48:00:00
#PBS -q smp
#PBS -J 1-103%5
#PBS -o /mnt/lustre/users/yswart/output/htstream.out
#PBS -e /mnt/lustre/users/yswart/output/htstream.err
#PBS -M yolandi01@sun.ac.za


cd /mnt/lustre/users/yswart

module load chpc/BIOMODULES
module load HTStream/1.3.1

start=`date +%s`
echo $HOSTNAME
echo "My PBS_ARRAY_ID:" $PBS_ARRAY_ID

sample=$(sed '${PBS_ARRAY_ID}q;d' samples.txt)

inpath="00-RawData"
outpath="01-HTS_Preproc"
[[ -d ${outpath}/${sample} ]] || mkdir ${outpath}/${sample}

echo "SAMPLE: ${sample}"

echo "${sample}" | sed 's/.$//'

call="hts_Stats -U ${inpath}/${sample}/*.fq.gz -L ${outpath}/${sample}/${sample}_htsStats.log | \
      hts_SeqScreener -A ${outpath}/${sample}/${sample}_htsStats.log | \
      hts_SeqScreener -s References/human_rrna.fasta -r -A ${outpath}/${sample}/${sample}_htsStats.log | \
      hts_AdapterTrimmer -A ${outpath}/${sample}/${sample}_htsStats.log | \
      hts_PolyATTrim  -A ${outpath}/${sample}/${sample}_htsStats.log | \
      hts_NTrimmer -A ${outpath}/${sample}/${sample}_htsStats.log | \
      hts_QWindowTrim -A ${outpath}/${sample}/${sample}_htsStats.log | \
      hts_LengthFilter -m 45 -A ${outpath}/${sample}/${sample}_htsStats.log | \
      hts_Stats -A ${outpath}/${sample}/${sample}_htsStats.log -f ${outpath}/${sample}/${sample}"

echo $call
eval $call

end=`date +%s`
runtime=$((end-start))
echo $runtime

