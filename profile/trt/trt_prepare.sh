#!/bin/bash

source utils.sh
source trt/trt_config.sh

# Create dirs
create_dir_if_missing ${RESULTS_DIR}
create_dir_if_missing ${TRT_RESULTS_DIR}

log_info "Clean directory: ${TRT_RESULTS_DIR}"
rm -rf ${TRT_RESULTS_DIR}/*

create_dir_if_missing ${TRT_RESULTS_DIR}/${DATASET_DIR}
create_dir_if_missing ${TRT_RESULTS_DIR}/${MODEL_DIR}

# Run prepare dataset
log_info "Prepare TRT dataset for:"
log_info "  MODEL      = ${MODEL}"
log_info "  INPUT_LEN  = ${INPUT_LEN}"
log_info "  OUTPUT_LEN = ${OUTPUT_LEN}"

python3 /app/tensorrt_llm/benchmarks/cpp/prepare_dataset.py \
	--tokenizer=${MODEL} \
	--stdout token-norm-dist \
	--num-requests=${NUM_SAMPLES} \
	--input-mean=${INPUT_LEN} \
	--output-mean=${OUTPUT_LEN} \
	--input-stdev=0 \
	--output-stdev=0 > ${TRT_RESULTS_DIR}/${DATASET_DIR}/rand_dataset_isl_${INPUT_LEN}_osl_${OUTPUT_LEN}.txt


