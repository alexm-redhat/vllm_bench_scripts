#!/bin/bash

source utils.sh
source trt_config.sh

# Sanity check
create_dir_if_missing $WORK_DIR

# Clean workdir
log_info "Clean directory: ${WORK_DIR}"
rm -rf $WORK_DIR/*

create_dir_if_missing ${WORK_DIR}/${DATASET_DIR}
create_dir_if_missing ${WORK_DIR}/${MODEL_DIR}

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
	--output-stdev=0 > ${WORK_DIR}/${DATASET}/rand_dataset_isl_${INPUT_LEN}_osl_${OUTPUT_LEN}.txt


