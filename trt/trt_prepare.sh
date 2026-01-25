#!/bin/bash

source config.sh

echo "Create directories in: $WORK_DIR"
mkdir ${WORK_DIR}
mkdir ${WORK_DIR}/${DATASET_DIR}
mkdir ${WORK_DIR}/${MODEL_DIR}

echo "Prepare TRT dataset for:"
echo "  MODEL      = ${MODEL}"
echo "  INPUT_LEN  = ${INPUT_LEN}"
echo "  OUTPUT_LEN = ${OUTPUT_LEN}"

python3 benchmarks/cpp/prepare_dataset.py \
	--tokenizer=${MODEL} \
	--stdout token-norm-dist \
	--num-requests=${NUM_SAMPLES} \
	--input-mean=${INPUT_LEN} \
	--output-mean=${OUTPUT_LEN} \
	--input-stdev=0 \
	--output-stdev=0 > ${WORK_DIR}/${DATASET}/rand_dataset_isl_${INPUT_LEN}_osl_${OUTPUT_LEN}.txt


