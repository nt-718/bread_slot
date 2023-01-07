#!/bin/bash

shopt -s extglob lastpipe
source ./db/players.txt
source ./db/items.txt
source ./db/points.txt
source ./db/events.txt
source ./db/game_history.txt

change_event() {
    change_lucky_item
    change_seasonal_item
    echo "lucky_item=$lucky_item" > ./db/events.txt
    echo "seasonal_item=$seasonal_item" >> ./db/events.txt
}

change_lucky_item() {
    source ./db/game_history.txt
    source ./db/events.txt
    
    if [[ $(($game_count % 10)) == 0 ]] && [[ "$player" == "${players[$((${#players[@]} - 1))]}" ]]; then
        lucky_item=${item_array[$(($RANDOM % ${#item_array[@]}))]}
        echo "lucky_item=$lucky_item" >> ./db/events.txt
    fi
}

change_seasonal_item() {
    source ./db/game_history.txt
    source ./db/events.txt
    
    if [[ $(($game_count % 5)) == 0 ]] && [[ "$player" == "${players[$((${#players[@]} - 1))]}" ]]; then
        seasonal_item=${item_array_to_use[$(($RANDOM % ${#item_array_to_use[@]}))]}
        echo "item_array=(${item_array[@]})" > ./db/items.txt
        item_array_to_use=(${item_array[@]} ${item_array[@]} ${item_array[@]} 🐵 $seasonal_item)
        echo "item_array_to_use=(${item_array_to_use[@]})" >> ./db/items.txt

        echo "seasonal_item=$seasonal_item" >> ./db/events.txt

        echo
        echo -e "\e[34m$seasonal_itemは今が旬!!\e[m"
        echo -e "\e[34m🎉$seasonal_itemが出やすくなりました🎉\e[m"
    fi
}

angel_event() {
	source ./db/game_history.txt

    if [[ "$angel_flag" == "$player" ]] && [[ "$game_count" != "$angel_count" ]]; then
		angel_flag=false
	fi
}

fever_time() {
    if [[ $fever_flag == true ]]; then
        if [[ $((RANDOM%+101)) -gt 70 ]]; then
            fever_flag="false"
            echo 
            echo -e "\e[34mフィーバータイム終了です!!\e[m"
        fi

    elif [[ $((RANDOM%+101)) -gt 80 ]]; then
        fever_flag="true"
        echo 
        echo -e "\e[34mフィーバータイムです!!\e[m"
        echo -e "\e[34m通常のポイント+1されます!!\e[m"
    fi
}