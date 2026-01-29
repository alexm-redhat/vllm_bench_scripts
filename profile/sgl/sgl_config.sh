
source config.sh

# SGL Image
export SGL_IMAGE=lmsysorg/sglang:latest

# Dirs
export CONTAINER_DIR="/app/profile"
export SGL_RESULTS_DIR="${CONTAINER_DIR}/${RESULTS_DIR}/sgl"

# Profile
export PROFILE=""
#export PROFILE="--profile"

# export PROFILE_STAGE="--profile-stage=all"
# export PROFILE_STAGE="--profile-stage=prefill"
export PROFILE_STAGE="--profile-stage=decode"