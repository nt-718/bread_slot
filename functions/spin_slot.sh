#!/bin/bash

shopt -s extglob lastpipe
source ./db/players.txt
source ./db/items.txt
source ./db/points.txt
source ./db/events.txt
source ./db/game_history.txt

slot_count=1
successive_point=0
num=1

spin_slot() {

	slot="${item_array_to_use[$(($RANDOM % ${#item_array_to_use[@]}))]} ${item_array_to_use[$(($RANDOM % ${#item_array_to_use[@]}))]} ${item_array_to_use[$(($RANDOM % ${#item_array_to_use[@]}))]}"

	first_value=`echo "$slot" | awk '{print $1}'`
	second_value=`echo "$slot" | awk '{print $2}'`
	third_value=`echo "$slot" | awk '{print $3}'`

	player_num=`get_index $player`

	if [ "$first_value" == "$second_value" -a "$first_value" == "$third_value" ]; then
		if [[ "$tomato_fes_flag" == true ]]; then
			echo
			if [[ "$slot" == "ð ð ð" ]]; then
				echo "æ®å¿µãð ð ðãå¼ãã¦ãã¾ã£ãï¼"
				tomato_point=$(($tomato_point + 3))
			else
				echo "æ®å¿µã$slotã¯ð ð ðã«å¤åãã"
				slot="ð ð ð"
			fi
		fi

		if [[ "$angel_flag" == "$player" ]]; then
			slot="${player_goods[$player_num]} ${player_goods[$player_num]} ${player_goods[$player_num]}"
		fi

		echo -e "\e[33m$slot_count: $slot Delisious! ð ð ð\e[m"
		count_point "$slot"
		insert_prev_item "$first_value"
		sed -i "2s/^//" ./db/all_pair_history.txt
		sed -i "3s/^/${num}: $player:$slot\n/" ./db/all_pair_history.txt
		num=$(($num + 1))
		change_lucky_item
	else
		echo "$slot_count: $slot"
	fi
	slot_count=$(($slot_count + 1))

}

count_point() {

    slot_result=$1
	mutch_count=$(($mutch_count + 1))

	first_value=`echo "$slot_result" | awk '{print $1}'`

    if [[ "$first_value" == "$prev_item" ]]; then
        successive_point=$(($successive_point + 1))
		echo "é£ç¶ãã¼ãã¹ï¼$slot_result"
		echo
    fi

	if [[ "$fever_flag" == "true" ]]; then
		fever_point=$(($fever_point + 1))
	fi

	if [[ "$lucky_item $lucky_item $lucky_item" == "$slot_result" ]]; then
		lucky_point=$(($lucky_point + 10))
		echo "â¨ $slot_result â¨"
		echo
	fi

	if [[ "$slot_result" == "ð ð ð" ]]; then
		tomato_point=$(($tomato_point + 3))
	fi

	if [[ "$slot_result" == "ð¿ ð¿ ð¿" ]]; then
		echo
		for i in `seq 1 ${LINES}`
		do
			echo -e "\e[35mð¿ ð¿ ð¿ ð¿ ð¿ ð¿ ð¿ ð¿ ð¿ ð¿\e[m"
			sleep 0.1
		done
		echo "ãã¤ã³ãã0ã«ãªãã¾ããã"
		devil_flag="true"
	fi

	if [[ "$slot_result" == "ð¼ ð¼ ð¼" ]]; then
		
		echo
		for i in `seq 1 ${LINES}`
		do
			echo -e "\e[35mð¼ ð¼ ð¼ ð¼ ð¼ ð¼ ð¼ ð¼ ð¼ ð¼\e[m"
			sleep 0.1
		done
		echo "æ¬¡ã®ã¿ã¼ã³æã£ããã®ã¯ãã¹ã¦å¥½ç©ã«ãªãã¾ãã"
		angel_flag="$player"
		angel_count=$game_count
	fi

	if [[ "$slot_result" == "ðµ ðµ ðµ" ]]; then
		monkey_point=$(($monkey_point + 10))
		echo
		monkey_array=(ð ð ð)
		eeee='\rð'

		for y in {1..10}
		do
			monkey_result=${monkey_array[$(($RANDOM % ${#monkey_array[*]}))]}
			if [[ $y == 10 ]]; then
				printf "${eeee}$monkey_resultð\n"
				sleep 0.5
			else
				printf "${eeee}$monkey_resultð"
			fi
			sleep 0.5
		done
	fi

	if [[ "$slot_result" == "ð¥ ð¥ ð¥" ]]; then
	    source ./db/events.txt
		echo "ð¥ãç²å¾ããï¼"
		echo
		new_eggs=()

		for i in `seq 0 $((${#players[@]} - 1))`
		do
			if [[ ${players[$i]} == "$player" ]]; then 
				if [[ ${eggs[$i]} == 0 ]]; then
					new_eggs+=("1")
				else
					new_eggs+=(${eggs[$i]})
				fi
			else
				new_eggs+=(${eggs[$i]})
			fi
		done

		echo "eggs=(${new_eggs[@]})" >> ./db/events.txt
		
	fi

	if [[ "$2" != "roulette" ]]; then
		if [[ $(($num % 10)) == 0 ]]; then
			ten_times_point=$(($ten_times_point + 5))
			echo -e "\e[35m$numåç®ãã¼ãã¹!\e[m"
			echo
		fi

		if [[ $(($num % 10)) == 2 ]] && [[ $num != 2 ]]; then
			bad_times_point=$(($bad_times_point + 6))
			echo -e "\e[35mæ®å¿µã$numåç®ã¢ã³ã©ãã­ã¼!\e[m"
			echo
		fi

		first_check=`grep "$slot_result" ./db/all_pair_history.txt`

		if [[ "$first_check" == "" ]]; then
			first_point=$(($first_point + 1))
			echo "ð $slot_result ð"
			echo
		fi
	fi

	if [[ "${player_goods[$player_num]} ${player_goods[$player_num]} ${player_goods[$player_num]}" == "$slot_result" ]]; then
		good_point=$(($good_point + 5))
		echo "ð $slot_result ð"
		echo
	fi
	
	if [[ "${player_bads[$player_num]} ${player_bads[$player_num]} ${player_bads[$player_num]}" == "$slot_result" ]]; then
		bad_point=$(($bad_point + 5))
		echo "ð¤¢ $slot_result ð¤¢"
		echo
	fi

	if [[ "$slot_result" == "ð ð ð" ]]; then
		if [[ $((RANDOM%+101)) -gt 70 ]]; then
			echo
			echo "ãããðã®æ§å­ãã»ã»ã»"
			cccc='\rð'
			apples=("ð" "ð")

			for y in {1..50}
			do
				apple=${apples[$(($RANDOM % ${#apples[*]}))]}
				printf "${cccc}$apple $apple $appleð"
				sleep 0.1
			done

			if [[ "$apple $apple $apple" == "ð ð ð" ]]; then
				echo ""
				echo "ðã«çªç¶å¤ç°ããï¼ï¼"
				echo "ðãã®ã¿ã¼ã³ã®å ç¹ã0ã«ãªãã¾ããð"
				sleep 1
				bad_apple="true"
			else
				echo "ä½ã«ãèµ·ãããªãã£ãã»ã»ã»"
			fi
		fi
	fi

}

get_index() {
	search_name=$1
	for i in `seq 0 $((${#players[@]} - 1))`
	do
		if [[ ${players[$i]} == "$search_name" ]]; then
			player_num=$i
		fi
	done
	echo $player_num
}

lucky_roulette() {
	
	echo 
	echo -e "\e[34mð¼ã©ãã­ã¼ã«ã¼ã¬ããð¼\e[m"
	sleep 1	
	aaaa='\rð'	
	new_array=(ð¼ ðµ ð¼ ðµ ${item_array[@]} ${item_array[@]} ${item_array[@]})
	for y in {1..50}
	do
		lucky_roulette_item=${new_array[$(($RANDOM % ${#new_array[*]}))]}
		if [[ $y == 50 ]]; then
			printf "${aaaa}$lucky_roulette_item $lucky_roulette_item $lucky_roulette_itemð\n"
		else
			printf "${aaaa}$lucky_roulette_item $lucky_roulette_item $lucky_roulette_itemð"
		fi
		sleep 0.1
	done

	res="$lucky_roulette_item $lucky_roulette_item $lucky_roulette_item"
	count_point "$res" "roulette"
	echo	
}

unlucky_roulette() {
	echo 
	echo -e "\e[31mð¿ã¢ã³ã©ãã­ã¼ã«ã¼ã¬ããð¿\e[m"
	sleep 1	

    bad_array=(ð¿ ð ðµ ${player_bads[@]} ð ðµ ${player_bads[@]} ð ðµ ${player_bads[@]})
	bbbb='\rð'

	for y in {1..50}
	do
		unlucky_roulette_item=${bad_array[$(($RANDOM % ${#bad_array[*]}))]}
		if [[ $y == 50 ]]; then
			printf "${bbbb}$unlucky_roulette_item $unlucky_roulette_item $unlucky_roulette_itemð\n"
		else
			printf "${bbbb}$unlucky_roulette_item $unlucky_roulette_item $unlucky_roulette_itemð"
		fi
		sleep 0.1
	done

	res="$unlucky_roulette_item $unlucky_roulette_item $unlucky_roulette_item"
	count_point "$res" "roulette"
	echo

}

spin_roulette() {
	if [[ $((RANDOM%+101)) -gt 80 ]]; then
		lucky_roulette
	fi

	if [[ $((RANDOM%+101)) -gt 95 ]]; then
		unlucky_roulette
	fi
}

reset_slot() {
	slot_count=1
	mutch_count=0
	successive_point=0
	fever_point=0
	first_point=0
	lucky_point=0
	tomato_point=0
	monkey_point=0
	ten_times_point=0
	bad_times_point=0
	good_point=0
	bad_point=0
    point_plus=0
    point_minus=0
	bad_apple="false"
	ghost_flag="false"
	change_preference_point=0
}