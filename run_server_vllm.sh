#!/bin/bash

source config.sh

CUDA_VISIBLE_DEVICES=$CUDA_GPUS vllm serve $MODEL \
  --port $PORT \
  --no-enable-prefix-caching \
  --tensor-parallel-size $NUM_GPUS \
  

  # --max-num-seqs 128 \
  # --max-model-len 16384 \
  # --data-parallel-size $NUM_GPUS \
  # --enable-expert-parallel \
  # --quantization="modelopt_fp4" \
