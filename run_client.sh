#!/bin/bash

source config.sh

vllm bench serve \
    --port $PORT \
    --model ${MODEL} \
    --dataset-name random \
    --max-concurrency ${CONCURRENCY} \
    --random-input-len ${INPUT_LEN} \
    --random-output-len ${OUTPUT_LEN} \
    --num-prompts ${NUM_PROMPTS} \
    --seed $(date +%s) \
    --percentile-metrics ttft,tpot,itl,e2el \
    --metric-percentiles 90,95,99 \
    --ignore-eos \
    --trust-remote-code



