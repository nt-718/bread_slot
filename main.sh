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
source ./functions/view_game_info.sh
source ./functions/gpt_advisor.sh

# main function

start_game
start_hour=`date +"%-H"`
start_minute=`date +"%-M"`

source ./db/players.txt
source ./db/items.txt

reset_slot

player=${players[0]}
if [[ `echo ${bot_array[@]} | grep "$player"` ]]; then
	paid_coin=1
	echo "Auto mode"
else
	set_spin_times
fi

while true
do
	if [[ "$paid_coin" == ":q" ]]; then
		break
	elif [[ "$paid_coin" == "change" ]]; then
		echo "好みを変更したターンはスロットを回すことができません。"
		read -p "5コインで好みを変更しますか？ y/N: " change_pref
    	if [ "$change_pref" == "N" -o "$change_pref" == "n" ]; then
			set_spin_times
			if [[ -z $paid_coin ]]; then
				paid_coin=1
			elif [[ $paid_coin -gt 5 ]]; then
				paid_coin=5
			elif [[ "$paid_coin" =~ ^[0-9]+$ ]]; then
				paid_coin=$paid_coin
			else
				paid_coin=1
			fi
		else
			change_preference
		fi
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
		sleep 0.05
	done

	spin_roulette
	egg_bonus
	calculate_point
	angel_event
	insert_point_data
	change_event
	show_summary > ./db/game_info.txt
	insert_game_data
	change_player "$player"
	reset_slot

	if [[ $fever_flag == true ]]; then
		echo
		echo -e "\e[34mフィーバー中です!!\e[m"
	fi
	
	if [[ "$game_count" == "$(($game_set + 1))" ]]; then
		finish_game
	fi

	free_time
	
	inflation_time

	abnormal_events

	echo
	echo -e "\e[35m$playerのターンです!\e[m"
	random_pay

	if [[ $ghost_flag == true ]]; then
		random_array=(1 2 3 4 5)
		dddd='\r👉'

		for y in {1..50}
		do
			random_pay_number=${random_array[$(($RANDOM % ${#random_array[*]}))]}
			if [[ $y == 50 ]]; then
				printf "${dddd}$random_pay_number👈\n"
				echo "$random_pay_numberコイン使用されました。"
				sleep 1
				paid_coin=$random_pay_number
			else
				printf "${dddd}$random_pay_number👈"
			fi
			sleep 0.1
		done
	else
		if [[ `echo ${bot_array[@]} | grep "$player"` ]]; then
			paid_coin=$(get_num)
			echo "$paid_coinコイン支払われました。"
			sleep 3
		else
			set_spin_times
		fi
	fi
done
