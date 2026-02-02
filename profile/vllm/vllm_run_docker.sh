#!/bin/bash
source sgl/sgl_config.sh

CONTAINER_NAME="vllm_auto_profile_${USER}"

remove_docker_if_exists $CONTAINER_NAME

docker run \
	-it \
	--ipc=host \
	--ulimit memlock=-1 \
	--ulimit stack=67108864 \
	--gpus=all \
	-v ${PROFILE_DIR}:${CONTAINER_PROFILE_DIR} \
	-v ${HF_HUB_CACHE}:${CONTAINER_HF_HUB_CACHE} \
	--env "HF_HUB_CACHE=${CONTAINER_HF_HUB_CACHE}" \
	-p ${CONTAINER_PORT}:${CONTAINER_PORT} \
	--name ${CONTAINER_NAME} \
	--rm \
	--shm-size 32g \
	$CUR_IMAGE \
	bash -c "cd $CONTAINER_DIR; time ./sgl/sgl_run.sh"


docker run --runtime nvidia --gpus all \
    -v ~/.cache/huggingface:/root/.cache/huggingface \
    --env "HF_TOKEN=$HF_TOKEN" \
    -p 8000:8000 \
    --ipc=host \
    vllm/vllm-openai:latest \
    --model Qwen/Qwen3-0.6B
