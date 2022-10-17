#!/bin/bash
#PBS -m abe
#PBS -N preprocessing
#PBS -l select=1:ncpus=24:mpiprocs=4
#PBS -P CBBI1195
#PBS -l walltime=48:00:00
#PBS -q serial
#PBS -o /mnt/lustre/users/yswart/output/htstream.out
#PBS -e /mnt/lustre/users/yswart/output/htstream.err
#PBS -M yolandi01@sun.ac.za


module load chpc/BIOMODULES
module load FastQC/0.11.5
## small thing, but best to start loading dependencies

# cd /mnt/lustre/users/yswart/
## to avoid possible script breakdown. sometimes is best to always declare the full path to a file.
wrk_dir="/mnt/lustre/users/yswart"

## bash array with samples
samples=($(ls -d $wrk_dir/00-Rawdata/*fq.gz | awk -F '00-Rawdata/' '{print $2}'))


init_idx=0 # first element from arrray ${samples[0]}
end_idx=$((${#samples[@]} -1)) ## since bash index starts at zero, it need fixing

for i in $(eval echo "{$init_idx..$end_idx}")
do
target_sample=${samples[i]}
target_sample=$(echo $target_sample | awk -F '.fq.gz' '{print $1}')
## run the pipe for each sample
fastqc /mnt/lustre/users/yswart/01-HTS_Preproc/$target_sample/$target_sample_SE.fastq.gz -o /mnt/lustre/users/yswart/01-HTS-multiqc-report/After_cleanup
done

cd /mnt/lustre/users/yswart/01-HTS-multiqc-report/After_cleanup

module load python/3.6.3
multiqc .
