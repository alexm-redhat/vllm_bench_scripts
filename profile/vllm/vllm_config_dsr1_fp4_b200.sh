
source config.sh
source vllm/vllm_config.sh

# MoE
export VLLM_USE_FLASHINFER_MOE_FP4=1
export VLLM_FLASHINFER_MOE_BACKEND="latency" # "throughput"

# Attn
export VLLM_ATTN_BACKEND=FLASHINFER_MLA