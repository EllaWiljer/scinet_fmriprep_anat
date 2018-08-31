#!/bin/bash
#SBATCH --nodes=1
#SBATCH --cpus-per-task=80
#SBATCH --time=11:00:00
#SBATCH --job-name fmriprep112_q08
#SBATCH --output=fmriprep112_q08_%j.txt


source ${HOME}/code/bids-on-scinet/env/source_qbatch_python_env.sh
module load singularity
module load gnu-parallel/20180322

## change this to the name of your dataset
dataset="HBN"

## put a freesurfer license file in your HOME so that this works!!!
export freesufer_license=$SCRATCH/freesurfer_license.txt

## set all the folder paths
sing_home=$SCRATCH/sing_home/fmriprep
indir=$SCRATCH/${dataset}/tmp
outdir=$SCRATCH/bids_outputs/${dataset}/fmriprep112_p08
workdir=$SCRATCH/work/${dataset}/fmriprep112_p08

## this line acutally makes all the folders
mkdir -p ${sing_home} ${outdir} ${workdir}

## acutally builds a submission script and submits all subjects the tasks (note we are using qbatch and gnu-parallel to run across participants)
cd ${indir}; ls -1d sub* | sed 's/sub-//g' | \
  parallel "echo singularity run \
  -H ${sing_home} \
  -B ${indir}:/bids \
  -B ${outdir}:/output \
  -B ${freesufer_license}:/freesurfer_license.txt \
  -B ${workdir}:/workdir \
  /scinet/course/ss2018/3_bm/2_imageanalysis/singularity_containers/poldracklab_fmriprep_1.1.2-2018-07-06-c9e7f793549f.img \
      /bids /output participant \
      --participant_label {} \
      --anat-only \
      --nthreads 10 \
      --omp-nthreads 10 \
      --output-space T1w template \
      --work-dir /workdir \
      --notrack --fs-license-file /freesurfer_license.txt" | \
      qbatch \
       --walltime 11:00:00 --nodes 1 --ppj 80 \
       --chunksize 8 --cores 8 \
       --workdir $sing_home \
       --jobname ${dataset}_fmriprep_anat \
--env none --header "module load singularity gnu-parallel/20180322" \
- 
