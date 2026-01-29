
source config.sh

# TRT Image
export TRT_IMAGE=nvcr.io/nvidia/tensorrt-llm/release:1.3.0rc0

# Dataset
export NUM_SAMPLES=1000

# Dirs
export CONTAINER_DIR="/app/profile"
export TRT_RESULTS_DIR="${CONTAINER_DIR}/${RESULTS_DIR}/trt"

# Profile
export PROFILE=""