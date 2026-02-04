#!/bin/bash

source utils.sh
source profile_config.sh

run_docker ${VLLM} ${VLLM_DOCKER_IMAGE}
