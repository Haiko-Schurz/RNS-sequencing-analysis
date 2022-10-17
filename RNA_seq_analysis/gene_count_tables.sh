#!/bin/bash

#PBS -m abe
#PBS -N STAR_test
#PBS -l select=1:ncpus=24:mpiprocs=4
#PBS -P CBBI1195
#PBS -l walltime=48:00:00
#PBS -q serial
#PBS -o /mnt/lustre/users/yswart/output/gene_count.out
#PBS -e /mnt/lustre/users/yswart/output/gene_count.err
#PBS -M yolandi01@sun.ac.za

mkdir 03-Counts
mkdir 03-Counts/tmp
for sample in `cat samples.txt`; do \
    echo ${sample}
    cat 02-STAR_alignment/${sample}/${sample}_ReadsPerGene.out.tab | tail -n +5 | cut -f4 > 03-Counts/tmp/${sample}.count
done
