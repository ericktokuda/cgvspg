#!/bin/bash

#SBATCH --job-name=cg
#SBATCH --output=matlab_parfor.out
#SBATCH --error=matlab_parfor.err
#SBATCH --time=12:00:00
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=6
#SBATCH --mem=10GB

module load matlab/2014a

matlab -nodisplay -nosplash < slurm.m
