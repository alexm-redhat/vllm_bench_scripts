
# Docker images
VLLM_DOCKER_IMAGE=vllm/vllm-openai:latest
SGL_DOCKER_IMAGE=lmsysorg/sglang:latest
TRT_DOCKER_IMAGE=nvcr.io/nvidia/tensorrt-llm/release:1.3.0rc0

# GPU
GPU_TYPE=${B200}

# Profiles
declare -A DSR1_NVFP4_DECODE_ONLY=(
  [model]="nvidia/DeepSeek-R1-NVFP4"
  [gpu_ids]="0,1,2,3"
  [input_len]=4
  [output_len]=1024
  [vllm_mode]="moe_fp4_trtllm_fa_mla_${GPU_TYPE}"
  [sgl_mode]="empty"
  [trt_mode]="moe_trtllm_${GPU_TYPE}"
)

declare -A QWEN3_235B_A22B_NVFP4_DECODE_ONLY=(
  [model]="nvidia/Qwen3-235B-A22B-NVFP4"
  [gpu_ids]="0,1"
  [input_len]=4
  [output_len]=1024
  [vllm_mode]="moe_fp4_trtllm_${GPU_TYPE}"
  [sgl_mode]="empty"
  [trt_mode]="moe_trtllm_${GPU_TYPE}"
)

PROFILES=(DSR1_NVFP4_DECODE_ONLY QWEN3_235B_A22B_NVFP4_DECODE_ONLY)

# Batch sizes
PROFILE_CONCURRENCIES="1 16"

# Profile on/off
VLLM_ENABLE_PROFILE=0
SGL_ENABLE_PROFILE=0
TRT_ENABLE_PROFILE=0

