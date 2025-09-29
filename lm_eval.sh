
source config.sh

lm_eval \
    --model local-completions \
    --model_args model=$MODEL,base_url=http://0.0.0.0:$PORT/v1/completions,num_concurrent=500,tokenized_requests=False \
    --tasks gsm8k \
    --num_fewshot 5
