#!/bin/bash

shopt -s extglob lastpipe
source ./db/players.txt
source ./db/items.txt
source ./db/points.txt
source ./db/events.txt
source ./db/game_history.txt

change_player() {

	if [[ "$1" == "${players[0]}" ]]; then
		player=${players[1]}
	else
		player=${players[0]}
	fi
	player="$player"
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
	fi

	echo "game_count=$game_count" > ./db/game_history.txt
	echo "prev_item=$prev_item" >> ./db/game_history.txt
	
}