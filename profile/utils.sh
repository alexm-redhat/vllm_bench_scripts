
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
    ${image} \
    bash -c "cd ${DOCKER_PROFILE_DIR}; time ${cmd}"

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

  _run_docker ${name} ${image} "./${framework}/${framework}_run.sh" 
}

create_result_dirs() {
  local result_dirs="$1"
  
  create_dir_if_missing ${result_dirs}

  log_info "Clean directory: ${result_dirs}"
  rm -rf ${result_dirs}/*

  create_dir_if_missing ${result_dirs}/${DATASETS_DIR}
  
}