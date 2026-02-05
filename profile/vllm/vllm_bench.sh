#!/bin/bash

source utils.sh
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
    model_dirname=$(echo "${model}" | sed 's/\//__/g')

    output_dir=${VLLM_DOCKER_RESULTS_DIR}/${model_dirname}
    create_dir_if_missing ${output_dir}
    
    for concurrency in ${PROFILE_CONCURRENCIES}; do
        (
            set -euo pipefail

            log_info "      Run concurrency = ${concurrency}"
            
            ((num_requests = concurrency * NUM_WAVES))
            
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
            
            test_filename="$(
                make_test_filename \
                    ${VLLM} \
                    ${model_dirname} \
                    ${num_gpus} \
                    ${concurrency} \
                    ${input_len} \
                    ${output_len} \
                    ${mode}
                )"
            result_filename="$(
                make_result_filename \
                    ${output_dir} \
                    ${test_filename}
                )"
            
            # Set profile vars
            profile_flag=""
            profile_json=""
            profile_prefix=""
            if is_vllm_profile_enabled; then
                log_info "VLLM profile is enabled."
                
                num_warmups=0
                start_iter=$(calc_start_iter ${num_warmups} ${NUM_WAVES} ${output_len})

                printf -v profiler_config_json \
                    '{"profiler":"cuda","delay_iterations":%d,"max_iterations":%d}' \
                    "$start_iter" "$NUM_TRACE_ITERS"

                profile_flag="--profile"
                profile_json="--profiler-config ${profiler_config_json}"
                
                trace_dirname="$(
                    make_trace_dirname \
                        ${output_dir} \
                        ${test_filename}
                    )"
                create_dir_if_missing ${trace_dirname}
                trace_file_prefix="${trace_dirname}/trace-${test_filename}"

                profile_prefix="nsys profile ${NSYS_DEFAULT_FLAGS} -o ${trace_file_prefix}"
            fi

            # Run
            run env CUDA_VISIBLE_DEVICES=${gpu_ids} ${profile_prefix} vllm bench throughput \
                --disable-log-requests \
                --async-engine \
                --backend vllm \
                --model ${model} \
                ${attn_backend} \
                --tensor-parallel-size ${num_gpus} \
                --dataset-name random \
                --random-input-len ${input_len} \
                --random-output-len ${output_len} \
                --max-num-seqs ${concurrency} \
                --num-prompts ${num_requests} \
                --output-json ${result_filename} \
                ${profile_flag} \
                ${profile_json} \
            
            # Convert nsys binary file to SQLite format (python can read it)
            if is_vllm_profile_enabled; then
                run nsys export \
                    --type=sqlite \
                    --output="${trace_file_prefix}.sqlite" \
                    ${trace_file_prefix}.nsys-rep
            fi
        
        )
    done
done

