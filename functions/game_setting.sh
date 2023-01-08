#!/bin/bash

shopt -s extglob lastpipe
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
        echo "プレイヤー1の名前を入力してください"
        read -p ">>" player0_name
        echo "プレイヤー２の名前を入力してください"
        read -p ">>" player1_name

        player_names=("$player0_name" "$player1_name")
        check_null
        player_goods=()
        player_bads=()

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
        while [[ $i != 2 ]]
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

        echo "player_points=(10 10)" > ./db/points.txt

        echo "players=(${player_names[0]} ${player_names[1]})" > ./db/players.txt
        echo "player_goods=(${player_goods[0]} ${player_goods[1]})" >> ./db/players.txt
        echo "player_bads=(${player_bads[0]} ${player_bads[1]})" >> ./db/players.txt

        echo "lucky_item=" > ./db/events.txt
        echo "seasonal_item=" >> ./db/events.txt
        echo "eggs=(0 0)" >> ./db/events.txt
        
        item_array_to_use=("${item_array[@]} ${item_array[@]} ${item_array[@]} 🐵")
        echo "item_array=(${item_array[@]})" > ./db/items.txt
        echo "item_array_to_use=(${item_array_to_use[@]})" >> ./db/items.txt

    fi

    echo -e "\e[35m${players[0]}のターンです!\e[m"
}

check_null() {
    for i in `seq 0 $((${#player_names[@]} - 1))`
    do
        if [[ -z "${player_names[$i]}" ]]; then
            player_names[$i]=player${i}
        fi
    done
}

finish_game() {
    source ./db/points.txt
    if [[ "$game_count" == "$(($game_set + 1))" ]]; then
		echo "Finish!!"
		echo
		
		echo "勝者は・・・"
		read Wait

		if [[ ${player_points[0]} < ${player_points[1]} ]]; then
			echo "👏 Winner 🎉${players[1]}🎉 👏"
		elif [[ ${player_points[0]} > ${player_points[1]} ]]; then
			echo "👏 Winner 🎉${players[0]}🎉 👏"
		else
			echo "Draw"
		fi
        exit
	fi
}