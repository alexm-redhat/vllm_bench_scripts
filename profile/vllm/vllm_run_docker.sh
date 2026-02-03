#!/bin/bash

source common.sh
source profile_config.sh

run_docker ${VLLM} ${VLLM_DOCKER_IMAGE}
