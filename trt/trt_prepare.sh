#!/bin/bash

source config.sh

DIR="/path/to/your/directory"

# Sanity check
if [ -d "$PROFILES_DIR" ]; then
    echo "Directory found: $PROFILES_DIR"
else
    echo "Error: Directory not found - $PROFILES_DIR"
    echo "Exiting script."
    exit 1
fi

# Create dirs
echo "Create directory: $WORK_DIR"
mkdir ${WORK_DIR}
echo "Create directory: ${WORK_DIR}/${DATASET_DIR}"
mkdir ${WORK_DIR}/${DATASET_DIR}
echo "Create directory: ${WORK_DIR}/${MODEL_DIR}"
mkdir ${WORK_DIR}/${MODEL_DIR}

# Run prepare dataset
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


