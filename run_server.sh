#!/bin/bash

source config.sh

# DeepSeek
# CUDA_VISIBLE_DEVICES=$CUDA_GPUS vllm serve $MODEL \
# 	--port $PORT \
# 	--no-enable-prefix-caching \
# 	--tensor-parallel-size ${NUM_GPUS} \


# VLLM_WORKER_MULTIPROC_METHOD="spawn" VLLM_MOE_DP_CHUNK_SIZE=128 VLLM_USE_STANDALONE_COMPILE=0
# GPTOSS
CUDA_VISIBLE_DEVICES=$CUDA_GPUS vllm serve $MODEL \
  --port $PORT \
  --no-enable-prefix-caching \
  --data-parallel-size $NUM_GPUS \
  --enable-expert-parallel \
  --max-num-seqs 128 \
  --max-model-len 8192 \
  
  # --tensor-parallel-size $NUM_GPUS \
  
  
  
  # --quantization="modelopt_fp4"


  
  # -O.cudagraph_mode=FULL_AND_PIECEWISE \
  
  # -O.cudagraph_mode=PIECEWISE

  
  # --load-format dummy \  
  
  # --host 0.0.0.0 \
  # --quantization="modelopt_fp4" \

  
  # 

  # 
  # -O '{"cudagraph_mode": "FULL_DECODE_ONLY"}' \
  

  # -O.cudagraph_mode=FULL_AND_PIECEWISE \
  
  
