#!/bin/bash

# APIキーを変数に格納
api_key=$(cat ~/dev/node/openai_secret_key.txt)

get_name_by_gpt() {

    prompt_text="あだ名を一つ考えて。出力に「」はなくていい。"
    request_data="{\"model\": \"text-davinci-003\", \"prompt\": \"$prompt_text\", \"temperature\": 1, \"max_tokens\": 1024}"
    
    completion_length=100
    completion=""

    while [[ $completion_length -gt 12 ]] || [[ $completion == "null" ]]
    do
        res=$(curl -s https://api.openai.com/v1/completions \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer ${api_key}" \
        -d "${request_data}")
        completion=$(echo $res | jq -r '.choices[0].text')

        completion_length=${#completion}
    done

    echo "$completion" | tr -d '\n'
}

get_food() {

    prompt_text="🍎と🍏と🥚と🍅以外で、食べ物もしくは飲み物の絵文字を7つ、食べ物+空白の形式で横並びに出力してください。"
    request_data="{\"model\": \"text-davinci-003\", \"prompt\": \"$prompt_text\", \"temperature\": 0.5, \"max_tokens\": 1024}"
    food_count=0

    while [[ $food_count != 10 ]]
    do
        echo "Thinking..."
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

prompt_text_theme=""

create_picure() {
    # APIのエンドポイント
    url='https://api.openai.com/v1/images/generations'

    prompt_text="$1"

    # 画像生成のパラメータを設定
    data="{
        \"prompt\": \"$prompt_text\",
        \"model\": \"image-alpha-001\",
        \"num_images\":1,
        \"size\":\"1024x1024\",
        \"response_format\":\"url\"
    }"

    # APIを呼び出し
    response=$(curl -X POST -H "Content-Type: application/json" -H "Authorization: Bearer ${api_key}" -d "${data}" "${url}")

    # レスポンスを見やすい形式で表示
    echo "Question!!"
    echo "この絵のテーマを当ててみよう！"
    echo $response | jq -r '.data[0].url'
}

make_theme() {

    prompt_text_theme="イラストを描きたいので、何かアイデアをください。1つだけでいいです。返答には~を描くやシーン、絵といった言葉は含まず、英語でしてください。"
    request_data="{\"model\": \"text-davinci-003\", \"prompt\": \"$prompt_text_theme\", \"temperature\": 0.5, \"max_tokens\": 1024}"

    res=$(curl -s https://api.openai.com/v1/completions \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer ${api_key}" \
    -d "${request_data}")

    picture_theme=$(echo $res | jq -r '.choices[0].text')

    echo "$picture_theme" | tr -d '\n'
    echo "$picture_theme" | tr -d '\n' > result.txt
}

gpt_guess() {

    echo "$prompt_text_theme"
    picture_theme=$(cat ./result.txt)

    prompt_text_compare="$picture_themeと$1という二つの文章の類似性を0から100の数字で表してください。"
    request_data="{\"model\": \"text-davinci-003\", \"prompt\": \"$prompt_text_compare\", \"temperature\": 0.5, \"max_tokens\": 1024}"

    res=$(curl -s https://api.openai.com/v1/completions \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer ${api_key}" \
    -d "${request_data}")

    completion=$(echo $res | jq -r '.choices[0].text')

    echo "$completion点!!" | tr -d '\n'

    echo "正解は$picture_theme"

}

gpt_game() {
    theme=`make_theme`
    create_picure "$theme"
    echo "答えを入力してください。" 
    read guess_text

    prompt_text_translate="$guess_textを英語に訳してください。"
    request_data="{\"model\": \"text-davinci-003\", \"prompt\": \"$prompt_text_translate\", \"temperature\": 0, \"max_tokens\": 1024}"

    res=$(curl -s https://api.openai.com/v1/completions \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer ${api_key}" \
    -d "${request_data}")

    completion=$(echo $res | jq -r '.choices[0].text')

    translated_text=`echo "$completion" | tr -d '\n'`

    gpt_guess "$translated_text"

}