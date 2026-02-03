#!/bin/bash


source common.sh
source profile_config.sh

create_clean_dir ${TRT_DOCKER_RESULTS_DIR}

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

    output_dir=${TRT_DOCKER_RESULTS_DIR}/${model_dir}
    create_dir_if_missing ${output_dir}

    datasets_dir=${output_dir}/${DATASETS_DIR}
    create_dir_if_missing ${datasets_dir}

    # Run prepare dataset
    log_info "Prepare TRT dataset for:"
    log_info "  MODEL      = ${model}"
    log_info "  INPUT_LEN  = ${input_len}"
    log_info "  OUTPUT_LEN = ${output_len}"
    datasets_file="${datasets_dir}/rand_dataset_isl_${input_len}_osl_${output_len}.txt"

    python3 /app/tensorrt_llm/benchmarks/cpp/prepare_dataset.py \
        --tokenizer=${model} \
        --stdout token-norm-dist \
        --num-requests=1000 \
        --input-mean=${input_len} \
        --output-mean=${output_len} \
        --input-stdev=0 \
        --output-stdev=0 > ${datasets_file}

    for concurrency in ${PROFILE_CONCURRENCIES}; do
        log_info "      Run concurrency = ${concurrency}"
        
        ((num_requests = concurrency * 4))
        
        # Set extra options
        mode=""
        yaml_flag=""
        if [[ -v profile[trt_mode] && -n "${profile[trt_mode]}" ]]; then
            mode="${profile[trt_mode]}"
            log_info "Set TRT MODE = ${mode}"
            yaml_file="trt/trt_mode_${mode}.yaml"
            log_info "Add yaml file: ${yaml_file}"
            yaml_flag="--extra_llm_api_options ${yaml_file}"
        fi
        
        output_file="$(
            make_output_filename \
                ${TRT} \
                ${output_dir} \
                ${num_gpus} \
                ${concurrency} \
                ${input_len} \
                ${output_len} \
                ${mode}
            )"
    
        #$PROFILE # TODO: FIX

        run env CUDA_VISIBLE_DEVICES=${gpu_ids} trtllm-bench \
            --model ${model} \
            throughput \
            --dataset ${datasets_file} \
            --num_requests ${num_requests} \
            --concurrency ${concurrency} \
            --tp ${num_gpus} \
            --eos_id -1 \
            --report_json ${output_file} \
            --streaming \
            ${yaml_flag} \
            
    done
done

