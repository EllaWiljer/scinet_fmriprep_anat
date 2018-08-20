#!/bin/bash
#SBATCH --nodes=1
#SBATCH --cpus-per-task=80
#SBATCH --time=11:00:00
#SBATCH --job-name ciftify_p08
#SBATCH --output=ciftify_p08_%j.txt

cd $SLURM_SUBMIT_DIR

module load singularity
module load gnu-parallel/20180322

dataset="HBN"
bids_input=$SCRATCH/${dataset}
export freesufer_license=$SCRATCH/freesurfer_license.txt
export ciftify_container=/scinet/course/ss2018/3_bm/2_imageanalysis/singularity_containers/tigrlab_fmriprep_ciftify_1.1.2-2.0.9-2018-07-31-d0ccd31e74c5.img
## build the mounts
sing_home=$SCRATCH/sing_home/ciftify
outdir=$SCRATCH/bids_outputs/${dataset}/fmriprep112_p08
workdir=$SCRATCH/work/${dataset}/fmriprep112_08

mkdir -p ${sing_home} ${outdir} ${workdir}

#trap the termination signal, and call the function 'trap_term' when
# that happens, so results may be saved.
## note..due to a silly bug in datman..the folder above the workdir needs to be readable

parallel -j 8 "singularity run \
  -H ${sing_home} \
  -B ${bids_input}:/bids \
  -B ${outdir}:/output \
  -B ${freesufer_license}:/freesurfer_license.txt \
  -B ${workdir}:/workdir \
  ${ciftify_container} \
      /bids /output participant \
      --participant_label={} \
      --fmriprep-workdir /workdir/${dataset} \
      --fs-license /freesurfer_license.txt \
      --n_cpus 10 \
      --fmriprep-args='--use-aroma'" \
::: "NDARAA075AMK" "NDARAD481FXF" "NDARAJ366ZFA" "NDARAM277WZT" "NDARAA536PTU" "NDARAE199TDD" "NDARAK187ZLP" "NDARAR025WX4"
