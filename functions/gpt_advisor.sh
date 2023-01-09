#!/bin/bash

# APIキーを変数に格納
api_key=$(cat ~/dev/node/openai_secret_key.txt)

get_name_by_gpt() {

    prompt_text="あだ名を一つだけ考えて。出力に「」はなくていい。"
    request_data="{\"model\": \"text-davinci-003\", \"prompt\": \"$prompt_text\", \"temperature\": 1, \"max_tokens\": 1024}"

    res=$(curl -s https://api.openai.com/v1/completions \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer ${api_key}" \
    -d "${request_data}")

    completion=$(echo $res | jq -r '.choices[0].text')

    echo "$completion" | tr -d '\n'
}

get_food() {

    prompt_text="🍎と🍏と🥚と🍅以外で、食べ物の絵文字を7つ、食べ物+空白の形式で横並びに出力してください。"
    request_data="{\"model\": \"text-davinci-003\", \"prompt\": \"$prompt_text\", \"temperature\": 1, \"max_tokens\": 1024}"
    food_count=0

    while [[ $food_count != 10 ]]
    do
        res=$(curl -s https://api.openai.com/v1/completions \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer ${api_key}" \
        -d "${request_data}")
        completion=$(echo $res | jq -r '.choices[0].text')
        food_array=($(echo "$completion" | tr -d '\n'))
        food_array+=(🍎 🥚 🍅)
        food_count=${#food_array[@]}
    done
    
    echo "item_array=(${food_array[@]})" > ./db/items.txt
    echo "今回の食材は・・・"
    echo "${food_array[@]}"
    echo
    
}