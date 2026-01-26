# TRT
export TRT_IMAGE=nvcr.io/nvidia/tensorrt-llm/release:1.3.0rc0

# Model
export MODEL=nvidia/DeepSeek-R1-NVFP4

# GPUs
export CUDA_VISIBLE_DEVICES=4,5,6,7
export NUM_GPUS=$(echo "$CUDA_VISIBLE_DEVICES" | awk -F',' '{print NF}')


# Dataset
export INPUT_LEN=4
export OUTPUT_LEN=1024

export NUM_SAMPLES=1000

# Runs
export CONCURRENCY_LIST="1 16"

# Dirs
export HOST_TRT_DIR="/home/alexm-redhat/code/vllm_bench_scripts/trt"
export CONTAINER_TRT_DIR="/root/trt"

export WORK_DIR="$CONTAINER_TRT_DIR/profiles"
export DATASET_DIR="dataset"
export MODEL_DIR=$(echo "$MODEL" | sed 's/\//__/g')

# Profile
export PROFILE=""