#!/bin/bash

#PBS -m abe
#PBS -N Star_index
#PBS -l select=1:ncpus=24:mpiprocs=4
#PBS -P CBBI1195
#PBS -l walltime=48:00:00
#PBS -q serial
#PBS -o /mnt/lustre/users/yswart/output/index.out
#PBS -e /mnt/lustre/users/yswart/output/index.err
#PBS -M yolandi01@sun.ac.za

start=`date +%s`
echo $HOSTNAME

wrk_dir="/mnt/lustre/users/yswart"
outpath="References/"


cd $outpath
wget ftp://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_human/release_34/GRCh38.primary_assembly.genome.fa.gz
gunzip GRCh38.primary_assembly.genome.fa.gz
FASTA="../GRCh38.primary_assembly.genome.fa"

wget ftp://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_human/release_34/gencode.v34.primary_assembly.annotation.gtf.gz
gunzip gencode.v34.primary_assembly.annotation.gtf.gz
GTF="../gencode.v34.primary_assembly.annotation.gtf"

mkdir star.overlap100.gencode.v34
cd star.overlap100.gencode.v34

module load chpc/BIOMODULES
module load STAR/2.5.3a

call="STAR
     --runThreadN 8 \
     --runMode genomeGenerate \
     --genomeDir . \
     --sjdbOverhang 100 \
     --sjdbGTFfile $GTF \
     --genomeFastaFiles $FASTA"

echo $call
eval $call

end=`date +%s`
runtime=$((end-start))
echo $runtime
