#!/bin/bash

source utils.sh
source trt/trt_config.sh

YAML_FILE="${TRT_RESULTS_DIR}/${MODEL_DIR}/extra_llm_api_options.yaml"

log_info "Create: ${YAML_FILE}"
cat > ${YAML_FILE} <<EOF
moe_config:
  backend: TRTLLM
EOF

log_info "Run bench:"
for CONCURRENCY in ${CONCURRENCY_LIST}; do
    ((NUM_REQUESTS = CONCURRENCY * 4))
    
    log_info "  Run iter:"
    log_info "    CONCURRENCY = ${CONCURRENCY}"

    $PROFILE run trtllm-bench \
        --model ${MODEL} \
        throughput \
        --extra_llm_api_options ${YAML_FILE} \
        --dataset ${TRT_RESULTS_DIR}/${DATASET_DIR}/rand_dataset_isl_${INPUT_LEN}_osl_${OUTPUT_LEN}.txt \
        --num_requests ${NUM_REQUESTS} \
        --concurrency ${CONCURRENCY} \
        --tp ${NUM_GPUS} \
        --eos_id -1 \
        --report_json ${TRT_RESULTS_DIR}/${MODEL_DIR}/trt_bench_tp__${NUM_GPUS}_batch__${CONCURRENCY}_isl__${INPUT_LEN}_osl__${OUTPUT_LEN}.json \
        --streaming
done

