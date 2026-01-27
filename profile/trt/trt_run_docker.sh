#!/bin/bash
source trt/trt_config.sh

CONTAINER_NAME=trt_alex

if docker container inspect $CONTAINER_NAME >/dev/null 2>&1; then
	docker container stop $CONTAINER_NAME
	docker container rm $CONTAINER_NAME
fi

docker run \
	-it \
	--ipc=host \
	--ulimit memlock=-1 \
	--ulimit stack=67108864 \
	--gpus=all \
	-v $WORK_DIR:$CONTAINER_DIR \
	-v $HF_HUB_CACHE:/root/hf_hub_cache \
	--env "HF_HUB_CACHE=/root/hf_hub_cache" \
	-p 30000:30000 \
	--name $CONTAINER_NAME \
	--rm \
	$TRT_IMAGE \
	bash -c "cd $CONTAINER_DIR; time ./trt_run.sh"
