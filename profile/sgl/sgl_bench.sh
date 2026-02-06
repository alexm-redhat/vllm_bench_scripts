#!/bin/bash

source utils.sh
source profile_config.sh

create_clean_dir ${SGL_DOCKER_RESULTS_DIR}

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

    output_dir=${SGL_DOCKER_RESULTS_DIR}/${model_dirname}
    create_dir_if_missing ${output_dir}
    
    for concurrency in ${PROFILE_CONCURRENCIES}; do
        (
            set -euo pipefail
            
            log_info "      Run concurrency = ${concurrency}"
            
            ((num_requests = concurrency * NUM_WAVES))

            # Set extra env vars
            mode=""
            if [[ -v profile[sgl_mode] && -n "${profile[sgl_mode]}" ]]; then
                mode=${profile[sgl_mode]}
                log_info "Set ${SGL} MODE = ${mode}"
                source "${SGL}/${SGL}_mode_${mode}.sh"
            fi

            test_filename="$(
                make_test_filename \
                    ${SGL} \
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

            # This will speedup capture for low batch sizes
            CUDA_GRAPH_FLAG=""
            if (( concurrency < 64 )); then
                CUDA_GRAPH_FLAG="--cuda-graph-max-bs=64"
            fi

            # Set profile env vars
            profile_flag=""
            profile_acts=""
            profile_stage=""
            profile_prefix=""
            if is_sgl_profile_enabled; then
                log_info "SGL profile is enabled."
                
                # Enable profile
                profile_flag="--profile"

                # Use NSYS
                profile_acts="--profile-activities CUDA_PROFILER"

                # Set profile stage
                profile_stage="--profile-stage=decode" # Can be either all, prefill or decode
                
                trace_file_prefix="$(
                    make_trace_file_prefix \
                        ${output_dir} \
                        ${test_filename}
                    )"

                profile_prefix="nsys profile ${NSYS_DEFAULT_FLAGS} -o ${trace_file_prefix}"
            fi

            # Run
            run env CUDA_VISIBLE_DEVICES=${gpu_ids} $profile_prefix python -m sglang.bench_one_batch \
                --model-path ${model} \
                --tp $num_gpus \
                --batch ${concurrency} \
                --input-len ${input_len} \
                --output-len ${output_len} \
                --result-filename ${result_filename} \
                $CUDA_GRAPH_FLAG \
                $profile_flag \
                $profile_acts \
                $profile_stage \

            # Convert nsys binary file to SQLite format (python can read it)
            if is_sgl_profile_enabled; then
                run nsys export \
                    --type=sqlite \
                    --output="${trace_file_prefix}.sqlite" \
                    ${trace_file_prefix}.nsys-rep
            fi
                
        )    
    done
done

