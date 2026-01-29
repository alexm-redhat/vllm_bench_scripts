#!/bin/bash

source utils.sh
source sgl/sgl_config.sh

log_info "Run bench:"
for CONCURRENCY in ${CONCURRENCY_LIST}; do
    ((NUM_REQUESTS = CONCURRENCY * 4))
    
    log_info "  Run iter:"
    log_info "    CONCURRENCY = ${CONCURRENCY}"

    # Process profile args (if needed)
    PROFILE=""
    PROFILE_ACTS=""
    PROFILE_STAGE=""
    export SGLANG_TORCH_PROFILER_DIR=""
    if [[ -v ENABLE_PROFILE && "$ENABLE_PROFILE" == "1" ]]; then
        log_info "Profile is enabled. Defining env vars."
        set -x
        
        # Enable profile
        PROFILE="--profile"

        # By default, torch profiler is used, enable this to use NSYS (TODO: Fix file placement)
        # PROFILE_ACTS="--profile-activities CUDA_PROFILER"

        # Set profile stage
        PROFILE_STAGE="--profile-stage=decode" # Can be either all, prefill or decode
        
        # Set profile output dir
        export SGLANG_TORCH_PROFILER_DIR="${CUR_RESULTS_DIR}/${MODEL_DIR}/${TRACES_DIR}/sgl_trace_tp__${NUM_GPUS}_batch__${CONCURRENCY}_isl__${INPUT_LEN}_osl__${OUTPUT_LEN}"
        
        set +x
        create_dir_if_missing ${SGLANG_TORCH_PROFILER_DIR}
        log_info "Clean directory: ${SGLANG_TORCH_PROFILER_DIR}"
        rm -rf ${SGLANG_TORCH_PROFILER_DIR}/*
    fi

    # Run
    run python -m sglang.bench_one_batch \
        --model-path ${MODEL} \
        --tp $NUM_GPUS \
        --max-running-requests ${CONCURRENCY} \
        --batch ${CONCURRENCY} \
        --input-len ${INPUT_LEN} \
        --output-len ${OUTPUT_LEN} \
        --result-filename ${CUR_RESULTS_DIR}/${MODEL_DIR}/sgl_bench_tp__${NUM_GPUS}_batch__${CONCURRENCY}_isl__${INPUT_LEN}_osl__${OUTPUT_LEN}.json \
        $PROFILE \
        $PROFILE_ACTS \
        $PROFILE_STAGE \

done

