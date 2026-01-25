# TRT
export TRT_IMAGE=nvcr.io/nvidia/tensorrt-llm/release:1.2.0rc8

# Model
export MODEL=nvidia/DeepSeek-R1-NVFP4

# Dataset
export INPUT_LEN=4
export OUTPUT_LEN=1000

export NUM_SAMPLES=1000

# Runs
export CONCURRENCY_LIST="1 16"

# Dirs
export HOST_TRT_DIR="/home/alexm-redhat/code/vllm_bench_scripts/trt"
export CONTAINER_TRT_DIR="/root/trt"

export PROFILES_DIR="$CONTAINER_TRT_DIR/profiles"

TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
CUR_DIR="run_$TIMESTAMP"

export WORK_DIR=$PROFILES_DIR/$CUR_DIR

export DATASET_DIR="dataset"
export MODEL_DIR=$(echo "$MODEL" | sed 's/\//__/g')