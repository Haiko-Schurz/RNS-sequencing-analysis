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
module load HTStream/1.3.1
## small thing, but best to start loading dependencies


## to avoid possible script breakdown. sometimes is best to always declare the full path to a file.
wrk_dir="/mnt/lustre/users/yswart"

## bash array with samples
samples=($(ls -d $wrk_dir/00-Rawdata/*fq.gz | awk -F '00-Rawdata/' '{print $2}'))

inpath="00-Rawdata" # this new path, need tod be relative to an existing one
outpath="01-HTS_Preproc_sampledata"
[[ -d $outpath ]] || mkdir $wrk_dir/$outpath

init_idx=0 # first element from arrray ${samples[0]} 
end_idx=$((${#samples[@]} -1)) ## since bash index starts at zero, it need fixing

for i in $(eval echo "{$init_idx..$end_idx}")
do
target_sample=${samples[i]}
target_sample=$(echo $target_sample | awk -F '.fq.gz' '{print $1}')
## run the pipe for each sample
hts_Stats -L $wrk_dir/$outpath/$target_sample'.json' -N 'initial stats' -U $wrk_dir/$inpath/$target_sample'.fastq.gz' | \
hts_SeqScreener -A $wrk_dir/$outpath/$target_sample'.json' -N 'screen phix' | \
hts_SeqScreener -A $wrk_dir/$outpath/$target_sample'.json' -N 'count the number of rRNA reads' -r -s $wrk_dir/References/human_rrna.fasta | \
hts_AdapterTrimmer -A $wrk_dir/$outpath/$target_sample'.json' -N 'trim adapters' | \
hts_PolyATTrim -A $wrk_dir/$outpath/$target_sample'.json' -N 'remove polyAT tails' | \
hts_NTrimmer -A $wrk_dir/$outpath/$target_sample'.json' -N 'remove any remaining N characters' | \
hts_QWindowTrim -A $wrk_dir/$outpath/$target_sample'.json' -N 'quality trim the end of reads' | \
hts_LengthFilter -A $wrk_dir/$outpath/$target_sample'.json' -N 'remove reads < 45bp' -n -m 45| \
hts_Stats -A $wrk_dir/$outpath/$target_sample'.json' -N 'final stats' -f $wrk_dir/$outpath/$target_sample
echo "Finished: " $target_sample "at: " date
date
done





end=`date +%s`
runtime=$((end-start))
echo $runtime 
      
