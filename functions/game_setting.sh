#!/bin/bash

source ./db/players.txt
source ./db/items.txt
source ./db/points.txt
source ./db/events.txt
source ./db/game_history.txt
source ./functions/selector.sh

start_game() {

    read -p "リセットしますか？ y/N: " reset

    if [ "$reset" == "N" -o "$reset" == "n" ]; then
        game_count=$game_count
        num=$(cat ./db/all_pair_history.txt | grep : | wc -l)
        game_count=$(($game_count + 1))
        num=$(($num + 1))

    else
        player_names=()

        echo "プレイ人数を入力してください"
        read -p ">>" how_many_players

        if [[ -z "$how_many_players" ]]; then
            how_many_players=2
            echo "2人プレイに設定しました"
        fi

        for i in `seq 0 $(($how_many_players - 1))`
        do
            echo "プレイヤー${i}の名前を入力してください"

            read -p ">>" player_name

            if [[ -z "$player_name" ]]; then
                player_names+=("player${i}")
            else
                player_names+=($player_name)
            fi
        done

        player_names=(${player_names[@]})

        player_goods=()
        player_bads=()
        player_eggs=()
        player_points=()

        read -p "ゲーム数を決めてください: " game_set
        if [[ -z $game_set ]]; then
            game_set=20

        elif [[ "$game_set" =~ ^[0-9]+$ ]]; then
            game_set=$game_set
        else
            game_set=20
        fi
        echo "$game_setゲームで終了します。"

        i=0
        while [[ $i != ${#player_names[@]} ]]
        do
            clear
            echo "${player_names[$i]}は好きなものを選択してください。"
            get_value "food_array"
            source ./functions/selector.sh
            player_goods+=("$selected_value")
            clear
            echo -e "${player_names[$i]}は\e[31m苦手なもの\e[mを選択してください。"
            get_value "food_array"
            source ./functions/selector.sh
            player_bads+=("$selected_value")
            player_points+=(10)
            player_eggs+=(0)

            [[ ${player_goods[$i]} == "" ]] && player_goods[$i]=${item_array[$(($RANDOM % ${#item_array[*]}))]}
            [[ ${player_bads[$i]} == "" ]] && player_bads[$i]=${item_array[$(($RANDOM % ${#item_array[*]}))]}
            
            random_test="true"

            while [[ $random_test == "true" ]]
            do
                if [[ "${player_bads[$i]}" == "${player_goods[$i]}" ]]; then
                    player_bads[$i]=${item_array[$(($RANDOM % ${#item_array[*]}))]}
                else
                    player_bads[$i]=${player_bads[$i]}
                    random_test="false"
                fi
            done

            i=$(($i + 1 ))
        done

        echo "HISTORY" > ./db/all_pair_history.txt
    	echo "" >> ./db/all_pair_history.txt
	    echo "" >> ./db/all_pair_history.txt

        echo "game_count=1" > ./db/game_history.txt
        echo "prev_item=" >> ./db/game_history.txt

        echo "player_points=(${player_points[@]})" > ./db/points.txt

        echo "players=(${player_names[@]})" > ./db/players.txt
        echo "player_goods=(${player_goods[@]})" >> ./db/players.txt
        echo "player_bads=(${player_bads[@]})" >> ./db/players.txt

        echo "lucky_item=" > ./db/events.txt
        echo "seasonal_item=" >> ./db/events.txt
        echo "eggs=(${player_eggs[@]})" >> ./db/events.txt
        
        item_array_to_use=("${item_array[@]} ${item_array[@]} ${item_array[@]} 🐵")
        echo "item_array=(${item_array[@]})" > ./db/items.txt
        echo "item_array_to_use=(${item_array_to_use[@]})" >> ./db/items.txt

    fi
    source ./db/players.txt
    echo -e "\e[35m${players[0]}のターンです!\e[m"
}

finish_game() {
    source ./db/points.txt
    echo "Finish!!"
    echo
    
    echo "勝者は・・・"
    read Wait

    most_point=`echo "(15 15 13)" | sort -nr | head -n 1`

    max=${player_points[0]}
    for n in "${player_points[@]}"; do
        ((n > max)) && max=$n
    done

    for i in `seq 0 $((${#player_points[@]} - 1))`
	do
		if [[ ${player_points[$i]} == "$max" ]]; then
			player_num=$i
            break
		fi
	done

    echo "👏 Winner 🎉${players[$player_num]}🎉 👏"
    
    exit
}

change_preference() {
    source ./db/players.txt
    new_player_goods=()
    new_player_bads=()

    clear
    echo "${player}は好きなものを選択してください。"
    get_value "food_array"
    source ./functions/selector.sh
    new_player_good="$selected_value"
    clear
    echo -e "${player}は\e[31m苦手なもの\e[mを選択してください。"
    get_value "food_array"
    source ./functions/selector.sh
    new_player_bad="$selected_value"
    
    for i in `seq 0 $((${#players[@]} - 1))`
    do
        if [[ ${players[$i]} == "$player" ]]; then 
            new_player_goods+=($new_player_good)
            new_player_bads+=($new_player_bad)
        else
            new_player_goods+=(${player_goods[$i]})
            new_player_bads+=(${player_bads[$i]})
        fi
    done

    echo "players=(${players[@]})" > ./db/players.txt
    echo "player_goods=(${new_player_goods[@]})" >> ./db/players.txt
    echo "player_bads=(${new_player_bads[@]})" >> ./db/players.txt

    paid_coin=0
    change_preference_point=5

}

specify_count() {
    history_count=$(cat ./db/all_pair_history.txt | grep : | wc -l)
}