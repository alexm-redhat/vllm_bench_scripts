
declare -A DSR1_NVFP4_DECODE_ONLY=(
  [model]="nvidia/DeepSeek-R1-NVFP4"
  [gpu_ids]="0,1,2,3"
  [input_len]=4
  [output_len]=1024
)

declare -A QWEN3_235B_A22B_NVFP4_DECODE_ONLY=(
  [model]="nvidia/Qwen3-235B-A22B-NVFP4"
  [gpu_ids]="0,1"
  [input_len]=4
  [output_len]=1024
)

PROFILES=(DSR1_NVFP4_DECODE_ONLY QWEN3_235B_A22B_NVFP4_DECODE_ONLY)
PROFILE_CONCURRENCIES="1 16"

