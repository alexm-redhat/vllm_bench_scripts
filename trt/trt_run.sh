#!/bin/bash

start_time=$(date +%s%N)

bash -x trt_prepare.sh
bash -x trt_bench.sh

end_time=$(date +%s%N)

duration_ns=$((end_time - start_time))
duration_sec=$(echo "scale=3; $duration_ns / 1000000000" | bc)

echo "FINISHED. Total duration = $duration_sec [secs]."