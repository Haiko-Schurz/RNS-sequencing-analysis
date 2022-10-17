#!/bin/bash

#PBS -N transfer_files
#PBS -l select=1:ncpus=24:mpiprocs=4
#PBS -P CBBI1195
#PBS -l walltime=96:00:00
#PBS -q smp
#PBS -I

rsync -avz --append tandem_rawdata mmeiring@scp.lengau.chpc.ac.za
