
source gen_config.sh
source profile_config.sh
source utils.sh

# SGL Image
DOCKER_IMAGE=lmsysorg/sglang:latest

# Output dir
DOCKER_RESULTS_DIR="${DOCKER_PROFILE_DIR}/${RESULTS_DIR}/sgl"

# Profile
ENABLE_PROFILE=0
