#!/bin/bash

source config.sh

## Profiler
#VLLM_PROFILER=""
VLLM_PROFILER="--profiler-config.torch_profiler_dir=/home/alexm-redhat/profiles/vllm_traces"

CUDA_VISIBLE_DEVICES=$CUDA_GPUS vllm serve $MODEL \
  --port $PORT \
  --no-enable-prefix-caching \
  --tensor-parallel-size $NUM_GPUS \
  --attention-config.backend=$VLLM_ATTN_BACKEND \
  --async-scheduling \
  --attention-config.use_trtllm_ragged_deepseek_prefill=True \
  -cc.pass_config.fuse_allreduce_rms=True \
  --quantization="modelopt_fp4" \
  $VLLM_PROFILER \

  

  # TRTLLM PREFILL
  #

  ## Fused AR+RMS
  #--compilation_config.pass_config.fuse_allreduce_rms true \

  ## Fused ROPE
  #--compilation_config.custom_ops+=+rotary_embedding \

  ## FP8 KV Cache
  #--kv-cache-dtype fp8 --compilation_config.pass_config.fuse_attn_quant true \

  # --max-num-seqs 128 \
  # --max-model-len 16384 \
  # --data-parallel-size $NUM_GPUS \
  # --enable-expert-parallel \
  # --quantization="modelopt_fp4" \
