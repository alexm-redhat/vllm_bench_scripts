#!/bin/bash

source config.sh

CUDA_VISIBLE_DEVICES=$CUDA_GPUS python -m sglang.launch_server \
  --model-path $MODEL \
  --port $PORT \
  --disable-chunked-prefix-cache \
  --tensor-parallel-size $NUM_GPUS \

  
  #--quantization modelopt_fp4 \
  #--max-running-requests 128 \
  #--mem-fraction-static 0.9 \
  #--max-total-tokens 32768 \


