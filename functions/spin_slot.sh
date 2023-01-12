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
		printf '\a'
		if [[ "$tomato_fes_flag" == true ]]; then
			echo
			if [[ "$slot" == "🍅 🍅 🍅" ]]; then
				echo "残念、🍅 🍅 🍅を引いてしまった！"
				tomato_point=$(($tomato_point + 3))
			else
				echo "残念、$slotは🍅 🍅 🍅に変化した"
				slot="🍅 🍅 🍅"
			fi
		fi

		if [[ "$angel_flag" == "$player" ]]; then
			slot="${player_goods[$player_num]} ${player_goods[$player_num]} ${player_goods[$player_num]}"
		fi

		echo -e "\e[33m$slot_count: $slot Delisious! 😋 😋 😋\e[m"
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
		echo "連続ボーナス：$slot_result"
		echo
    fi

	if [[ "$fever_flag" == "true" ]]; then
		fever_point=$(($fever_point + 1))
	fi

	if [[ "$lucky_item $lucky_item $lucky_item" == "$slot_result" ]]; then
		lucky_point=$(($lucky_point + 10))
		echo "✨ $slot_result ✨"
		echo
	fi

	if [[ "$slot_result" == "🍅 🍅 🍅" ]]; then
		tomato_point=$(($tomato_point + 3))
	fi

	if [[ "$slot_result" == "👿 👿 👿" ]]; then
		echo
		for i in `seq 1 ${LINES}`
		do
			echo -e "\e[35m👿 👿 👿 👿 👿 👿 👿 👿 👿 👿\e[m"
			sleep 0.1
		done
		echo "ポイントが0になりました。"
		devil_flag="true"
	fi

	if [[ "$slot_result" == "👼 👼 👼" ]]; then
		
		echo
		for i in `seq 1 ${LINES}`
		do
			echo -e "\e[35m👼 👼 👼 👼 👼 👼 👼 👼 👼 👼\e[m"
			sleep 0.1
		done
		echo "次のターン揃ったものはすべて好物になります。"
		angel_flag="$player"
		angel_count=$game_count
	fi

	if [[ "$slot_result" == "🐵 🐵 🐵" ]]; then
		monkey_point=$(($monkey_point + 10))
		echo
		monkey_array=(🙈 🙉 🙊)
		eeee='\r👉'

		for y in {1..10}
		do
			monkey_result=${monkey_array[$(($RANDOM % ${#monkey_array[*]}))]}
			if [[ $y == 10 ]]; then
				printf "${eeee}$monkey_result👈\n"
				sleep 0.5
			else
				printf "${eeee}$monkey_result👈"
			fi
			sleep 0.5
		done
		if [[ $monkey_result == "🙈" ]]; then
			echo ""
			echo "見ていない、何も見ていない。"
			echo "現実逃避したが-10ポイント"
		elif [[ $monkey_result == "🙉" ]]; then
			echo ""
			echo "聞いてない、何も聞いていない。"
			echo "現実逃避したが-10ポイント"
		else
			echo ""
			echo "言ってない、何も言っていない。"
			echo "現実逃避したが-10ポイント"
		fi
	fi

	if [[ "$slot_result" == "🥚 🥚 🥚" ]]; then
	    source ./db/events.txt
		echo "🥚を獲得した！"
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
			echo -e "\e[35m$num個目ボーナス!\e[m"
			echo
		fi

		if [[ $(($num % 10)) == 2 ]] && [[ $num != 2 ]]; then
			bad_times_point=$(($bad_times_point + 6))
			echo -e "\e[35m残念、$num個目アンラッキー!\e[m"
			echo
		fi

		first_check=`grep "$slot_result" ./db/all_pair_history.txt`

		if [[ "$first_check" == "" ]]; then
			first_point=$(($first_point + 1))
			echo "🎉 $slot_result 🎉"
			echo
		fi
	fi

	if [[ "${player_goods[$player_num]} ${player_goods[$player_num]} ${player_goods[$player_num]}" == "$slot_result" ]]; then
		good_point=$(($good_point + 5))
		echo "😍 $slot_result 😍"
		echo
	fi
	
	if [[ "${player_bads[$player_num]} ${player_bads[$player_num]} ${player_bads[$player_num]}" == "$slot_result" ]]; then
		bad_point=$(($bad_point + 5))
		echo "🤢 $slot_result 🤢"
		echo
	fi

	if [[ "$slot_result" == "🍎 🍎 🍎" ]]; then
		if [[ $((RANDOM%+101)) -gt 70 ]]; then
			echo
			echo "おや、🍎の様子が・・・"
			cccc='\r👉'
			apples=("🍎" "🍏" "🍎")

			for y in {1..50}
			do
				apple=${apples[$(($RANDOM % ${#apples[*]}))]}
				printf "${cccc}$apple $apple $apple👈"
				sleep 0.1
			done

			if [[ "$apple $apple $apple" == "🍏 🍏 🍏" ]]; then
				echo ""
				echo "🍏に突然変異した！！"
				echo "🍏このターンの加点が0になりました🍏"
				sleep 1
				bad_apple="true"
			else
				echo "何にも起こらなかった・・・"
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

stop_roulette() {
	read -t 0.05 -s -n 1 c
	case $c in
	s )
		input_key="s";;
	* )
		input_key="";;
	esac
}

lucky_roulette() {
	sleep 1	
	aaaa='\r👉'	
	new_array=(👼 🐵 👼 🐵 ${item_array[@]} ${item_array[@]} ${item_array[@]})	
	echo 
	echo -e "\e[34m👼ラッキールーレット👼\e[m"
	if [[ -z "`echo ${bot_array[@]} | grep "$player"`" ]]; then
		echo -e "\e[34m"Sキーを押してください。"\e[m"
		while :
		do
			lucky_roulette_item=${new_array[$(($RANDOM % ${#new_array[*]}))]}
			printf "${aaaa}$lucky_roulette_item $lucky_roulette_item $lucky_roulette_item👈"
			stop_roulette
			if [[ "$input_key" == "s" ]]; then
				break
			fi

			sleep 0.05
		done
	else
		for y in {1..50}
		do
			lucky_roulette_item=${new_array[$(($RANDOM % ${#new_array[*]}))]}
			if [[ $y == 50 ]]; then
				printf "${aaaa}$lucky_roulette_item $lucky_roulette_item $lucky_roulette_item👈\n"
			else
				printf "${aaaa}$lucky_roulette_item $lucky_roulette_item $lucky_roulette_item👈"
			fi
			sleep 0.1
		done
	fi

	input_key=""
	res="$lucky_roulette_item $lucky_roulette_item $lucky_roulette_item"
	count_point "$res" "roulette"
	echo	
}

unlucky_roulette() {
	sleep 1	
    bad_array=(👿 🍅 🐵 ${player_bads[@]} 🍅 🐵 ${player_bads[@]} 🍅 🐵 ${player_bads[@]})
	bbbb='\r👉'	
	echo 
	echo -e "\e[31m👿アンラッキールーレット👿\e[m"

	if [[ -z "`echo ${bot_array[@]} | grep "$player"`" ]]; then
		echo -e "\e[34m"Sキーを押してください。"\e[m"
		while :
		do
			unlucky_roulette_item=${bad_array[$(($RANDOM % ${#bad_array[*]}))]}
			printf "${bbbb}$unlucky_roulette_item $unlucky_roulette_item $unlucky_roulette_item👈"
			stop_roulette
			if [[ "$input_key" == "s" ]]; then
				break
			fi

			sleep 0.05
		done
	else
		for y in {1..50}
		do
			unlucky_roulette_item=${bad_array[$(($RANDOM % ${#bad_array[*]}))]}
			if [[ $y == 50 ]]; then
				printf "${bbbb}$unlucky_roulette_item $unlucky_roulette_item $unlucky_roulette_item👈\n"
			else
				printf "${bbbb}$unlucky_roulette_item $unlucky_roulette_item $unlucky_roulette_item👈"
			fi
			sleep 0.1
		done
	fi

	input_key=""
	res="$unlucky_roulette_item $unlucky_roulette_item $unlucky_roulette_item"
	count_point "$res" "roulette"
	echo

}

spin_roulette() {
	if [[ $((RANDOM%+101)) -gt 90 ]]; then
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


get_num() {

	paid_coin=1

	for i in `seq 0 $((${#players[@]} - 1))`
    do
        if [[ "${players[$i]}" == "$player" ]]; then
			lucky_item_check=${player_goods[$i]}
			break
        fi
    done

	count=$(cat ./db/all_pair_history.txt | grep : | wc -l)

	if [[ $inflation_flag == true ]]; then
		paid_coin=1
	fi

	if [[ $free_flag == true ]]; then
		paid_coin=5
	fi
    
    if [[ $(($count % 10)) == 1 ]] && [[ $(($count % 10)) == 2 ]]; then
		paid_coin=$1

	elif [[ $(($count % 10)) -lt 5 ]]; then
		if [[ $lucky_item_check == $seasonal_item ]]; then
			paid_coin=$(($paid_coin + 2))
		fi
		paid_coin=$paid_coin

    elif [[ $(($count % 10)) == 9 ]]; then
		paid_coin=1

    elif [[ $(($count % 10)) == 8 ]]; then
		paid_coin=2

    elif [[ $(($count % 10)) == 7 ]]; then
		paid_coin=3

    elif [[ $(($count % 10)) == 6 ]]; then
		paid_coin=4
    fi

    if [[ $angel_flag == true ]]; then
		paid_coin=5
	elif [[ $tomato_fes_flag == true ]] && [[ $lucky_item == "🍅" ]]; then
		paid_coin=5
	elif [[ $tomato_fes_flag == true ]]; then
		paid_coin=1
	fi

	if [[ $paid_coin -gt 5 ]]; then
		paid_coin=5
	elif [[ $paid_coin -lt 1 ]]; then
		paid_coin=1
	fi

	echo $paid_coin

}

set_spin_times() {
	printf "何コイン使いますか?:>> "
	return_code='\r何コイン使いますか?:>> '
	while :
	do
		case $(key_input_test) in
		enter)
			selected_num=$selected_num
			printf "${return_code}""$selected_num\n"
			paid_coin=$selected_num
			break;;
		up)
			selected_num=$(($selected_num + 1 ))
			[[ $selected_num -gt 5 ]] && selected_num=1
			
			printf "${return_code}""$selected_num";;
		down)
			selected_num=$(($selected_num - 1 ))
			[[ $selected_num -lt 1 ]] && selected_num=5
			
			printf "${return_code}""$selected_num";;
		esac
	done
}


key_input_test() {
	ESC=$(printf '%b' "\033")
	read -s -n3 key 2>/dev/null >&2
	if [[ $key = $ESC[A ]]; then
		echo "up"
	fi
	if [[ $key = $ESC[B ]]; then
		echo "down"
	fi
	if [[ $key = ""  ]]; then
		echo "enter"
	fi
}
