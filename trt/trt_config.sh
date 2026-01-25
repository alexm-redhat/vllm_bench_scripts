# Model
export MODEL=nvidia/DeepSeek-R1-NVFP4

# Dataset
export INPUT_LEN=4
export OUTPUT_LEN=1000

export NUM_SAMPLES=1000

# Runs
export CONCURRENCY_LIST="1 16"

# Dirs
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
CUR_DIR="run_$TIMESTAMP"
export WORK_DIR=/root/profiles/${CUR_DIR}

export DATASET_DIR="dataset"
export MODEL_DIR=$(echo "$MODEL" | sed 's/\//__/g')