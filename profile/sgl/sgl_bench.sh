#!/bin/bash

source utils.sh
source sgl/sgl_config.sh


log_info "Run bench:"
for CONCURRENCY in ${CONCURRENCY_LIST}; do
    ((NUM_REQUESTS = CONCURRENCY * 4))
    
    log_info "  Run iter:"
    log_info "    CONCURRENCY = ${CONCURRENCY}"

    python -m sglang.bench_one_batch \
        --model-path ${MODEL} \
        --batch ${CONCURRENCY} \
        --input-len ${INPUT_LEN} \
        --output-len ${OUTPUT_LEN} \
        --result-filename ${SGL_RESULTS_DIR}/${MODEL_DIR}/sgl_bench_tp__${NUM_GPUS}_batch__${CONCURRENCY}_isl__${INPUT_LEN}_osl__${OUTPUT_LEN}.json \
        $PROFILE \
        $PROFILE_STAGE \
    
done

