#!/bin/bash

vcfdir=/mnt/lustre/users/yswart/eQTL/vcfdir
edir=/mnt/lustre/users/yswart/eQTL/chunks
indir=/mnt/lustre/users/yswart/eQTL/TB_Healthy_B
la_cov=/mnt/lustre/users/yswart/eQTL/combined_bed/master
globalcov=/mnt/lustre/users/yswart/eQTL/TANDEM.all_covariates.txt


for chr in {1..22}; do

        outdir=${indir}/chr${chr}
        geno=${vcfdir}/TANDEM_chr${chr}.vcf.recode.vcf
        localcov=${la_cov}/chr${chr}.localcov.tsv


        for chunk in `ls ${edir} | grep "chr${chr}.expression"` ; do
                gene=${edir}/${chunk}
                suf=`echo ${gene} | sed 's/.*expression\.//' | sed 's/\..*//'`
                echo "Starting chr $chr chunk $suf"
                out="${outdir}/LocalAA-GlobalAA-allpairs-chr${chr}-${suf}_afr.tsv"
                Rscript ${indir}/eqtl_localaa_globalaa_afr.R ${chr} ${gene} ${globalcov} ${geno} ${localcov} ${out}
        done
done


