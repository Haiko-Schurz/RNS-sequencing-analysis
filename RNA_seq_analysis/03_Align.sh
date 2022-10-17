#!/bin/bash

#PBS -m abe
#PBS -N STAR_alignment
#PBS -l select=1:ncpus=24:mpiprocs=4
#PBS -P CBBI1195
#PBS -l walltime=48:00:00
#PBS -q serial
#PBS -o /mnt/lustre/users/yswart/output/alignment.out
#PBS -e /mnt/lustre/users/yswart/output/alignment.err
#PBS -M yolandi01@sun.ac.za


wrk_dir="/mnt/lustre/users/yswart"

module load chpc/BIOMODULES
module load STAR/2.5.3a

start=`date +%s`
echo $HOSTNAME


## bash array with samples
samples=($(ls -d $wrk_dir/00-Rawdata/*fq.gz | awk -F '00-Rawdata/' '{print $2}'))

inpath="00-Rawdata" # this new path, need tod be relative to an existing one
outpath="02-STAR_alignment"
[[ -d $outpath ]] || mkdir $wrk_dir/$outpath

init_idx=0 # first element from arrray ${samples[0]}
end_idx=$((${#samples[@]} -1)) ## since bash index starts at zero, it need fixing

for i in $(eval echo "{$init_idx..$end_idx}")
do
target_sample=${samples[i]}
target_sample=$(echo $target_sample | awk -F '.fq.gz' '{print $1}')
## run the pipe for each sample

call="STAR
     --runThreadN 8 \
     --genomeDir  \
     --outSAMtype BAM SortedByCoordinate \
     --readFilesCommand zcat \
     --readFilesIn 01-HTS_Preproc/$target_samples/$target_samples_SE.fastq.gz \
     --quantMode GeneCounts \
     --outFileNamePrefix $outpath/$target_samples/$target_samples_ \
     > $outpath/$target_samples/$target_samples-STAR.stdout 2> $outpath/$target_samples/$target_samples-STAR.stderr"

echo $call
eval $call;
done

end=`date +%s`
runtime=$((end-start))
echo $runtime
