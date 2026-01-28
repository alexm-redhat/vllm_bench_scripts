
source config.sh

# TRT
export SGL_IMAGE=lmsysorg/sglang:latest

# Dirs
export CONTAINER_DIR="/root/profile"
export SGL_RESULTS_DIR="${CONTAINER_DIR}/${RESULTS_DIR}/sgl"

# Profile
export PROFILE=""