#!/bin/bash

shopt -s extglob lastpipe
source ./db/points.txt
source ./db/events.txt
source ./db/game_history.txt

source ./functions/calculate_point.sh
source ./functions/change_event.sh
source ./functions/game_setting.sh
source ./functions/spin_slot.sh
source ./functions/game_data.sh

# main function

start_game

source ./db/players.txt
source ./db/items.txt

reset_slot() {
	slot_count=1
	mutch_count=0
	successive_point=0
	fever_point=0
	lucky_point=0
	tomato_point=0
	monkey_point=0
	good_point=0
	bad_point=0
    point_plus=0
    point_minus=0
	bad_apple="false"
}

reset_slot

player=${players[0]}
read -p "何コイン使いますか? " paid_coin

while true
do
	if [[ "$paid_coin" == ":q" ]]; then
		break
	elif [[ -z $paid_coin ]]; then
		paid_coin=1
 	elif [[ "$paid_coin" =~ ^[0-9]+$ ]]; then
		paid_coin=$paid_coin
	else
		paid_coin=1
	fi

	spin_times=$(($paid_coin * 100))
	for i in `seq 1 $spin_times`;
	do
		spin_slot
		sleep 0.07
	done

	spin_roulette
	calculate_point
	angel_event
	insert_game_data
	insert_point_data
	change_event
	change_player "$player"
	reset_slot

	if [[ $fever_flag == true ]]; then
		echo
		echo -e "\e[34mフィーバー中です!!\e[m"
	fi
	echo
	echo -e "\e[35m$playerのターンです!\e[m"
	read -p "何コイン使いますか? " paid_coin
done

# =================================================