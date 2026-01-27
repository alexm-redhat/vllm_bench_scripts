#!/bin/bash

source utils.sh
source vllm/vllm_config.sh

# Create clean dirs
create_dir_if_missing ${VLLM_RESULTS_DIR}

log_info "Clean directory: ${VLLM_RESULTS_DIR}"
rm -rf ${VLLM_RESULTS_DIR}/*

create_dir_if_missing ${VLLM_RESULTS_DIR}/${MODEL_DIR}
