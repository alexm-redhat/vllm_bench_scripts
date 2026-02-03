source gen_config.sh

_log() {
  local level="$1"
  shift
  local message="$*"
  local timestamp

  timestamp="$(date '+%Y-%m-%d %H:%M:%S')"
  echo "$timestamp [$level] $message"
}

log_info() {
  _log INFO "$@"
}

log_warn() {
  _log WARN "$@"
}

log_error() {
  _log ERROR "$@" >&2
}

log_debug() {
  _log DEBUG "$@"
}

create_dir_if_missing() {
  local dir="$1"

  if [[ -z "$dir" ]]; then
    log_error "No directory path provided"
    return 1
  fi

  log_info "Checking directory: $dir"

  if [[ -d "$dir" ]]; then
    log_info "  -- Directory already exists: $dir"
    return 0
  fi

  log_info "  -- Directory does not exist, create: $dir"

  mkdir "$dir" || {
    log_error "  -- Failed to create directory: $dir"
    return 1
  }
}

run() {
    echo "+ $*"
    "$@"
}

remove_docker_if_exists() {
  local name="$1"

  if [[ -z "$name" ]]; then
    log_error "No container name provided"
    return 1
  fi
  
  if docker container inspect $name >/dev/null 2>&1; then
	  log_warn "Container $name already exists. Stopping and removing."
    docker container stop $name
	  docker container rm $name
  fi

}

_run_docker() {
  local name="$1"
  local image="$2"
  local cmd="$3"

  if [[ -z "${name}" ]]; then
    log_error "No container name provided"
    return 1
  fi
  
  if [[ -z "${image}" ]]; then
    log_error "No container image provided"
    return 1
  fi

  if [[ -z "${cmd}" ]]; then
    log_error "No container cmd provided"
    return 1
  fi
  
  docker run \
    -it \
    --rm \
    --ipc=host \
    --ulimit memlock=-1 \
    --ulimit stack=67108864 \
    --shm-size 32g \
    --gpus=all \
    -v ${PROFILE_DIR}:${DOCKER_PROFILE_DIR} \
    -v ${HF_HUB_CACHE}:${DOCKER_HF_HUB_CACHE} \
    --env "HF_HUB_CACHE=${DOCKER_HF_HUB_CACHE}" \
    -p ${DOCKER_PORT}:${DOCKER_PORT} \
    --name ${name} \
    --entrypoint /bin/bash \
    ${image} \
    -c "cd ${DOCKER_PROFILE_DIR}; time ${cmd}"

}

run_docker() {
  local framework="$1"
  local image="$2"

  if [[ -z "${framework}" ]]; then
    log_error "No framework name provided"
    return 1
  fi
  
  if [[ -z "${image}" ]]; then
    log_error "No container image provided"
    return 1
  fi

  local name="${framework}_auto_profile_${USER}"
  
  # source ${framework}/${framework}_config.sh
  
  remove_docker_if_exists $name

  _run_docker ${name} ${image} "./${framework}/${framework}_bench.sh" 
}

create_clean_dir() {
  local dir="$1"

  create_dir_if_missing ${dir}

  log_info "Cleaning directory: ${dir}"
  rm -rf ${dir}/*

}

make_output_filename() {
  local framework="$1"
  local output_dir="$2"
  local num_gpus="$3"
  local concurrency="$4"
  local input_len="$5"
  local output_len="$6"
  local mode="${7:-}"

  # Validate required parameters
  if [[ -z "$framework" || -z "$output_dir" || -z "$num_gpus" || -z "$concurrency" || -z "$input_len" || -z "$output_len" ]]; then
    echo "Error: missing required parameter" >&2
    echo "Usage: make_output_filename <framework> <output_dir> <num_gpus> <concurrency> <input_len> <output_len> [mode]" >&2
    return 1
  fi

  local filename
  filename="${output_dir}/${framework}_bench_tp_${num_gpus}_batch_${concurrency}_isl_${input_len}_osl_${output_len}"

  if [[ -n "$mode" ]]; then
    filename+="_mode_${mode}"
  fi

  filename+=".json"

  echo "$filename"
}