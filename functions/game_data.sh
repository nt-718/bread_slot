#!/bin/bash

source ./db/players.txt
source ./db/items.txt
source ./db/points.txt
source ./db/events.txt
source ./db/game_history.txt

change_player() {

	for i in `seq 0 $((${#players[@]} - 1))`
    do
        if [[ "${players[$i]}" == "$player" ]]; then
			if [[ "$i" == $((${#players[@]} - 1)) ]]; then
				player="${players[0]}"
			else
				player="${players[$(($i + 1))]}"
			fi
			break
        fi
    done
}

insert_prev_item() {
	source ./db/game_history.txt
	prev_item="$1"
	echo "prev_item=$prev_item" >> ./db/game_history.txt
}

insert_game_data() {
	source ./db/game_history.txt

	if [[ "${players[$((${#players[@]} - 1))]}" == "$player" ]]; then
		game_count=$(($game_count + 1))
		fever_time
		tomato_festival
	fi

	echo "game_count=$game_count" > ./db/game_history.txt
	echo "prev_item=$prev_item" >> ./db/game_history.txt
	
}