#!/bin/bash
source trt/trt_config.sh

CONTAINER_NAME="trt_auto_profile_${USER}"

remove_docker_if_exists $CONTAINER_NAME

docker run \
	-it \
	--rm \
	--ipc=host \
	--ulimit memlock=-1 \
	--ulimit stack=67108864 \
	--gpus=all \
	-v $WORK_DIR:$CONTAINER_DIR \
	-v $HF_HUB_CACHE:/app/hf_hub_cache \
	--env "HF_HUB_CACHE=/app/hf_hub_cache" \
	-p 30000:30000 \
	--name $CONTAINER_NAME \
	$TRT_IMAGE \
	
	
	# bash -c "cd $CONTAINER_DIR; time ./trt/trt_run.sh"

