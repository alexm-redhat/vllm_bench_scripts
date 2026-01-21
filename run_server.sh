#!/bin/bash

source config.sh

# DeepSeek
# CUDA_VISIBLE_DEVICES=$CUDA_GPUS vllm serve $MODEL \
# 	--port $PORT \
# 	--no-enable-prefix-caching \
# 	--tensor-parallel-size ${NUM_GPUS} \


# CUDA_VISIBLE_DEVICES=$CUDA_GPUS python -m sglang.launch_server \
#   --model-path $MODEL \
#   --port $PORT \
#   --disable-chunked-prefix-cache \
#   --tensor-parallel-size $NUM_GPUS \
#   --max-running-requests 128 \
#   --max-total-tokens 32768 \
#   --mem-fraction-static 0.9 \
#   --quantization modelopt_fp4 \



CUDA_VISIBLE_DEVICES=$CUDA_GPUS vllm serve $MODEL \
  --port $PORT \
  --no-enable-prefix-caching \
  --tensor-parallel-size $NUM_GPUS \
  --max-num-seqs 128 \
  --max-model-len 16384 \
  
  #--quantization="modelopt_fp4" \
  # --data-parallel-size $NUM_GPUS \
  # --enable-expert-parallel \
  
  
  
  
  


  
  # -O.cudagraph_mode=FULL_AND_PIECEWISE \
  
  # -O.cudagraph_mode=PIECEWISE

  
  # --load-format dummy \  
  
  # --host 0.0.0.0 \
  # --quantization="modelopt_fp4" \

  
  # 

  # 
  # -O '{"cudagraph_mode": "FULL_DECODE_ONLY"}' \
  

  # -O.cudagraph_mode=FULL_AND_PIECEWISE \
  
  
