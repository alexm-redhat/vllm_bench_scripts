#!/bin/bash

if [[ -z "${1:-}" ]]; then
  log_error "Missing config argument. For example, use "dsr1_fp4_b200" to execute the config_dsr1_fp4_b200.sh mode"
  exit 1
fi

source utils.sh
source vllm/vllm_config_$1.sh

export ATTN_BACKEND=""
if [[ -n "$VLLM_ATTN_BACKEND" ]]; then  
  log_info "Set attn backend to ${VLLM_ATTN_BACKEND}"
  export ATTN_BACKEND="--attention-backend ${VLLM_ATTN_BACKEND}"
fi

export PROFILE=""
# export PROFILE="--profile"

log_info "Run bench:"
for CONCURRENCY in $CONCURRENCY_LIST; do
    ((NUM_REQUESTS = CONCURRENCY * 4))
    
    log_info "  Run iter:"
    log_info "    CONCURRENCY = ${CONCURRENCY}"

    run vllm bench throughput \
        --disable-log-requests \
        --async-engine \
        --backend vllm \
        --model ${MODEL} \
        ${ATTN_BACKEND} \
        ${PROFILE} \
        --tensor-parallel-size ${NUM_GPUS} \
        --dataset-name random \
        --random-input-len ${INPUT_LEN} \
        --random-output-len ${OUTPUT_LEN} \
        --max-num-seqs ${CONCURRENCY} \
        --num-prompts ${NUM_REQUESTS} \
        --output-json ${VLLM_RESULTS_DIR}/${MODEL_DIR}/vllm_bench_tp__${NUM_GPUS}_batch__${CONCURRENCY}_isl__${INPUT_LEN}_osl__${OUTPUT_LEN}.json

done

