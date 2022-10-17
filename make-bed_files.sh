#!/bin/bash

while read ind;
do
    for i in range(1, 99, 2):
            for chr in {1..22}; do awk '{print $"$i"}' local_haps.chr${chr} > ${ind}_A.tmp ; done ; done < id_list.txt


while read ind
do
    for i in range(2, 98, 2):
            for chr in {1..22};
            do awk '{print $i}' local_haps.chr${chr} > ${ind}_B.tmp ;
            done
    done
done < id_list.txt
