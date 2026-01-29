
source config.sh

# SGL Image
export CUR_IMAGE=lmsysorg/sglang:latest

# Dirs
export CONTAINER_DIR="/app/profile"
export CUR_RESULTS_DIR="${CONTAINER_DIR}/${RESULTS_DIR}/sgl"
export TRACES_DIR="traces"

# Profile
export ENABLE_PROFILE=1
