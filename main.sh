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

reset_slot

player=${players[0]}
read -p "何コイン使いますか? " paid_coin

while true
do
	if [[ "$paid_coin" == ":q" ]]; then
		break
	elif [[ -z $paid_coin ]]; then
		paid_coin=1
	elif [[ $paid_coin -gt 5 ]]; then
		paid_coin=5
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
	egg_bonus
	calculate_point
	angel_event
	insert_game_data
	insert_point_data
	change_event
	show_summary
	change_player "$player"
	reset_slot

	if [[ $fever_flag == true ]]; then
		echo
		echo -e "\e[34mフィーバー中です!!\e[m"
	fi
	
	free_time
	random_pay

	echo
	echo -e "\e[35m$playerのターンです!\e[m"
	if [[ $ghost_flag == true ]]; then
		random_array=(1 2 3 4 5)
		dddd='\r👉'

		for y in {1..50}
		do
			random_pay_number=${random_array[$(($RANDOM % ${#random_array[*]}))]}
			if [[ $y == 50 ]]; then
				printf "${dddd}$random_pay_number👈\n"
				echo "$random_pay_numberコイン使用されました。"
				read Wait
				paid_coin=$random_pay_number
			else
				printf "${dddd}$random_pay_number👈"
			fi
			sleep 0.1
		done
	else
		read -p "何コイン使いますか? " paid_coin
	fi
done

# =================================================