#!/bin/bash

source utils.sh
source sgl/sgl_config.sh

# Create clean dirs
create_dir_if_missing ${SGL_RESULTS_DIR}

log_info "Clean directory: ${SGL_RESULTS_DIR}"
rm -rf ${SGL_RESULTS_DIR}/*

create_dir_if_missing ${SGL_RESULTS_DIR}/${MODEL_DIR}
