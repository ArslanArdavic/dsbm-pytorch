#!/bin/bash
#SBATCH --account=project_465002822
#SBATCH --partition=dev-g
#SBATCH --job-name=mnist
#SBATCH --output=slurm/log/mnist_%j.out
#SBATCH --error=slurm/log/mnist%j.err
#SBATCH --nodes=1
#SBATCH --gpus-per-node=1            # Number of GPUs per node (max of 8)
#SBATCH --ntasks=1          
#SBATCH --cpus-per-task=7           # Use --gpus-per-node*7 CPUs on LUMI-G nodes
#SBATCH --mem-per-gpu=60G           
#SBATCH --time=00:30:00               # time limit

# this module facilitates the use of singularity containers on LUMI
module purge
module use /appl/local/laifs/modules
module load lumi-aif-singularity-bindings

# set MIOPEN temp folder
MIOPEN_DIR=$(mktemp -d)
export MIOPEN_CUSTOM_CACHE_DIR=$MIOPEN_DIR/cache
export MIOPEN_USER_DB=$MIOPEN_DIR/config

# Monitoring via wandb
export WANDB_API_KEY="60eae699ddc5a31f103b2c7be45a2c4115cae2bd"
export WANDB_ENTITY="arda-arslan-allab"

SIF=/project/project_465002822/containers/graph-found-20260401.sif

# Tell RCCL to use Slingshot interfaces and GPU RDMA
export NCCL_SOCKET_IFNAME=hsn0,hsn1,hsn2,hsn3
export NCCL_NET_GDR_LEVEL=PHB

srun singularity run -B /scratch/project_465002822,/project/project_465002822 $SIF bash -c \
    'python main.py num_steps=3 num_iter=5 method=dbdsb first_num_iter=100 gamma_min=0.034 gamma_max=0.034 first_coupling=ind'
