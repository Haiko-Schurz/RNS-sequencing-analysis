#!/bin/bash

#split expression into chunks
for i in {1..22}; do split -d -l 50 TANDEM_GRCh38.chr${i}.expression "/mnt/lustre/users/yswart/eQTL/chunks/TANDEM_GRCh38.chr${i}.expression.";  done

##Paste header in eveery file
header=header_expressionfile.txt

    for i in {1..22} ; do
            for file in `ls /mnt/lustre/users/yswart/eQTL/chunks  | grep "chr${i}.expression"`
            do
                    cat ${header} > /mnt/lustre/users/yswart/eQTL/chunks/tmp.chr${i}.txt
                    cat /mnt/lustre/users/yswart/eQTL/chunks/${file} >> /mnt/lustre/users/yswart/eQTL/chunks/tmp.chr${i}.txt
                    rm /mnt/lustre/users/yswart/eQTL/chunks/${file}
                    mv /mnt/lustre/users/yswart/eQTL/chunks/tmp.chr${i}.txt /mnt/lustre/users/yswart/eQTL/chunks/${file}
            done
    done
