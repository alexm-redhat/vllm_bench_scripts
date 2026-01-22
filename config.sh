## IP/PORT
export PORT=8123
export BASE_URL="http://0.0.0.0:"$PORT

## GPUS
# export CUDA_GPUS=0,1,2,3,4,5,6,7
export CUDA_GPUS=3,4,5,6

export NUM_GPUS=$(echo "$CUDA_GPUS" | awk -F',' '{print NF}')

## MODEL
# export MODEL=nvidia/Llama-3.3-70B-Instruct-FP8
# export MODEL=meta-llama/Llama-3.3-70B-Instruct
# export MODEL=deepseek-ai/DeepSeek-R1-0528
export MODEL=nvidia/DeepSeek-R1-NVFP4
# export MODEL=nvidia/DeepSeek-R1-FP4
# export MODEL=openai/gpt-oss-120b
# export MODEL=deepseek-ai/DeepSeek-V2-Lite

## DeepSeek Flags
# export VLLM_USE_FLASHINFER_MOE_FP8=1
export VLLM_USE_FLASHINFER_MOE_FP4=1

# export VLLM_FLASHINFER_MOE_BACKEND="throughput"
export VLLM_FLASHINFER_MOE_BACKEND="latency"

# export VLLM_ATTENTION_BACKEND=CUTLASS_MLA
export VLLM_ATTENTION_BACKEND=FLASHINFER_MLA

## GPTOSS Flags
# Pick only one out of the two for MoE implementation
# bf16 activation for MoE. matching reference precision (default).
# export VLLM_USE_FLASHINFER_MXFP4_BF16_MOE=1 
# mxfp8 activation for MoE. faster, but higher risk for accuracy.
# export VLLM_USE_FLASHINFER_MOE_MXFP4_MXFP8=1 

## Prompt-only
# export INPUT_LEN=8192
# export OUTPUT_LEN=1

## Decode-only
export INPUT_LEN=4
export OUTPUT_LEN=1024

## B1
# export CONCURRENCY=1
# export NUM_PROMPTS=5

## B16
export CONCURRENCY=16
export NUM_PROMPTS=64

## B256
# export CONCURRENCY=256
# export NUM_PROMPTS=1024


