#!/bin/bash

bash -c "./vllm/vllm_prepare.sh"
bash -c "./vllm/vllm_bench.sh dsr1_fp4_b200"