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

            # Process profile args (if needed)
            PROFILE_FLAG=""
            PROFILE_ACTS=""
            PROFILE_STAGE=""
            export SGLANG_TORCH_PROFILER_DIR=""
            if [[ -v ENABLE_PROFILE && "$ENABLE_PROFILE" == "1" ]]; then
                log_info "Profile is enabled. Defining env vars."
                set -x
                
                # Enable profile
                PROFILE_FLAG="--profile"

                # By default, torch profiler is used, enable this to use NSYS (TODO: Fix file placement)
                # PROFILE_ACTS="--profile-activities CUDA_PROFILER"

                # Set profile stage
                PROFILE_STAGE="--profile-stage=decode" # Can be either all, prefill or decode
                
                # Set profile output dir
                local traces_dir=${output_dir}/${TRACES_DIR}
                export SGLANG_TORCH_PROFILER_DIR="${traces_dir}/sgl_trace_tp__${num_gpus}_batch__${concurrency}_isl__${input_len}_osl__${output_len}"
                
                set +x

                # Create traces/profile dirs (if needed)
                create_dir_if_missing ${traces_dir}
                create_dir_if_missing ${SGLANG_TORCH_PROFILER_DIR}
                
            fi

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

            # Run
            run env CUDA_VISIBLE_DEVICES=${gpu_ids} python -m sglang.bench_one_batch \
                --model-path ${model} \
                --tp $num_gpus \
                --batch ${concurrency} \
                --input-len ${input_len} \
                --output-len ${output_len} \
                --result-filename ${result_filename} \
                $CUDA_GRAPH_FLAG \
                $PROFILE_FLAG \
                $PROFILE_ACTS \
                $PROFILE_STAGE \
                
        )    
    done
done

