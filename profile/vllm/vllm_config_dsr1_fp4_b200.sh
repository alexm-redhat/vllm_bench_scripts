
source vllm/vllm_config.sh

log_info "Defining env vars for dsr1_fp4_b200"

set -x

# MoE
export VLLM_USE_FLASHINFER_MOE_FP4=1
export VLLM_FLASHINFER_MOE_BACKEND="latency" # "throughput"

# Attn
export VLLM_ATTN_BACKEND=FLASHINFER_MLA

set +x