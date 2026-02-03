#!/bin/bash

source common.sh
source profile_config.sh

create_clean_dir ${VLLM_DOCKER_RESULTS_DIR}

# TODO: FIX
export PROFILE=""
# export PROFILE="--profile"

log_info "Run profiles:"

for p in "${PROFILES[@]}"; do
    declare -n profile="$p"
    model=${profile[model]}
    gpu_ids=${profile[gpu_ids]}
    input_len=${profile[input_len]}
    output_len=${profile[output_len]}
    log_info "  Profiling:"
    log_info "    model      = ${model}"
    log_info "    gpu_ids    = ${gpu_ids}"
    log_info "    input_len  = ${input_len}"
    log_info "    output_len = ${output_len}"

    num_gpus=$(echo "${gpu_ids}" | awk -F',' '{print NF}')
    model_dir=$(echo "${model}" | sed 's/\//__/g')

    output_dir=${VLLM_DOCKER_RESULTS_DIR}/${model_dir}
    create_dir_if_missing ${output_dir}
    
    for concurrency in ${PROFILE_CONCURRENCIES}; do
        (
            set -euo pipefail

            log_info "      Run concurrency = ${concurrency}"
            
            ((num_requests = concurrency * 4))
            
            # Set extra env vars
            mode=""
            if [[ -v profile[vllm_mode] && -n "${profile[vllm_mode]}" ]]; then
                mode=${profile[vllm_mode]}
                log_info "Set VLLM MODE = ${mode}"
                source "${VLLM}/${VLLM}_mode_${mode}.sh"
            fi

            # Set attn backend
            attn_backend=""
            if [[ -v VLLM_ATTN_BACKEND && -n "$VLLM_ATTN_BACKEND" ]]; then
                log_info "Set attn backend to ${VLLM_ATTN_BACKEND}"
                attn_backend="--attention-backend ${VLLM_ATTN_BACKEND}"
            fi
            
            output_file="$(
                make_output_filename \
                    ${VLLM} \
                    ${output_dir} \
                    ${num_gpus} \
                    ${concurrency} \
                    ${input_len} \
                    ${output_len} \
                    ${mode}
                )"

            run env CUDA_VISIBLE_DEVICES=${gpu_ids} vllm bench throughput \
                --disable-log-requests \
                --async-engine \
                --backend vllm \
                --model ${model} \
                ${attn_backend} \
                ${PROFILE} \
                --tensor-parallel-size ${num_gpus} \
                --dataset-name random \
                --random-input-len ${input_len} \
                --random-output-len ${output_len} \
                --max-num-seqs ${concurrency} \
                --num-prompts ${num_requests} \
                --output-json ${output_file} \
        
        )
    done
done

