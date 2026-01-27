# Model
export MODEL=nvidia/DeepSeek-R1-NVFP4

# GPUs
export CUDA_VISIBLE_DEVICES=4,5,6,7
export NUM_GPUS=$(echo "$CUDA_VISIBLE_DEVICES" | awk -F',' '{print NF}')

# Dataset
export INPUT_LEN=4
export OUTPUT_LEN=1024

# Dirs
export WORK_DIR="/home/alexm-redhat/code/vllm_bench_scripts/profile"

export RESULTS_DIR="results"
export DATASET_DIR="dataset"
export MODEL_DIR=$(echo "$MODEL" | sed 's/\//__/g')

# Runs
export CONCURRENCY_LIST="1 16"