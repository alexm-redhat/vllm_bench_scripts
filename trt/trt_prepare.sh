#!/bin/bash

source trt_config.sh

# Sanity check
if [ -d "$WORK_DIR" ]; then
    echo "Directory found: $WORK_DIR"
else
    echo "Error: Directory not found - $WORK_DIR"
    echo "Exiting script."
    exit 1
fi

# Clean workdir
echo "Clean directory: ${WORK_DIR}"
rm -rf $WORK_DIR/*

echo "Create directory: ${WORK_DIR}/${DATASET_DIR}"
mkdir ${WORK_DIR}/${DATASET_DIR}
echo "Create directory: ${WORK_DIR}/${MODEL_DIR}"
mkdir ${WORK_DIR}/${MODEL_DIR}

# Run prepare dataset
echo "Prepare TRT dataset for:"
echo "  MODEL      = ${MODEL}"
echo "  INPUT_LEN  = ${INPUT_LEN}"
echo "  OUTPUT_LEN = ${OUTPUT_LEN}"
python3 /app/tensorrt_llm/benchmarks/cpp/prepare_dataset.py \
	--tokenizer=${MODEL} \
	--stdout token-norm-dist \
	--num-requests=${NUM_SAMPLES} \
	--input-mean=${INPUT_LEN} \
	--output-mean=${OUTPUT_LEN} \
	--input-stdev=0 \
	--output-stdev=0 > ${WORK_DIR}/${DATASET}/rand_dataset_isl_${INPUT_LEN}_osl_${OUTPUT_LEN}.txt


