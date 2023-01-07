#!/bin/bash

shopt -s extglob lastpipe
source ./db/players.txt
source ./db/items.txt
source ./db/points.txt
source ./db/events.txt
source ./db/game_history.txt

slot_count=1
successive_point=0

spin_slot() {

	slot="${item_array_to_use[$(($RANDOM % ${#item_array_to_use[@]}))]} ${item_array_to_use[$(($RANDOM % ${#item_array_to_use[@]}))]} ${item_array_to_use[$(($RANDOM % ${#item_array_to_use[@]}))]}"

	first_value=`echo "$slot" | awk '{print $1}'`
	second_value=`echo "$slot" | awk '{print $2}'`
	third_value=`echo "$slot" | awk '{print $3}'`

	player_num=`get_index $player`

	if [ "$first_value" == "$second_value" -a "$first_value" == "$third_value" ]; then
		
		if [[ "$angel_flag" == "$player" ]]; then
			slot="${player_goods[$player_num]} ${player_goods[$player_num]} ${player_goods[$player_num]}"
		fi

		echo -e "\e[33m$slot_count: $slot Delisious! 😋 😋 😋\e[m"
		count_point "$slot"
		insert_prev_item "$first_value"
	else
		echo "$slot_count: $slot"
	fi
	slot_count=$(($slot_count + 1))

}

count_point() {

    slot_result=$1
	mutch_count=$(($mutch_count + 1))

    if [[ "$first_value" == "$prev_item" ]]; then
        successive_point=$(($successive_point + 1))
    fi

	if [[ "$fever_flag" == "true" ]]; then
		fever_point=$(($fever_point + 1))
	fi

	if [[ "$lucky_item $lucky_item $lucky_item" == "$slot_result" ]]; then
		lucky_point=$(($lucky_point + 10))
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
		for i in `seq 1 ${LINES}`
		do
			echo -e "\e[35m🐵 🐵 🐵 🐵 🐵 🐵 🐵 🐵 🐵 🐵\e[m"
			sleep 0.1
		done
	fi

	# if [[ "$slot_result" == "🥚 🥚 🥚" ]]; then
	# 	echo
	# 	echo "🥚を獲得した！"
	# 	echo

	# 	if [[ "$player" == "pororon" ]] && [[ "$egg_count_pororon" == 0 ]]; then
	# 		egg_count_pororon=1

	# 		echo "pororon=$pororon" > ./score.txt
	# 		echo "kiki=$kiki" >> ./score.txt
	# 		echo "pororon_good=$pororon_good" >> ./score.txt
	# 		echo "pororon_bad=$pororon_bad" >> ./score.txt
	# 		echo "kiki_good=$kiki_good" >> ./score.txt
	# 		echo "kiki_bad=$kiki_bad" >> ./score.txt
	# 		echo "lucky_item=$lucky_item" >> ./score.txt
	# 		echo "pororon_egg=🥚" >> ./score.txt
	# 		echo "kiki_egg=$kiki_egg" >> ./score.txt
	# 	fi
	# 	egg_count_pororon=$egg_count_pororon

	# 	if [[ "$player" == "kiki" ]] && [[ "$egg_count_kiki" == 0 ]]; then
	# 		egg_count_kiki=1

	# 		echo "pororon=$pororon" > ./score.txt
	# 		echo "kiki=$kiki" >> ./score.txt
	# 		echo "pororon_good=$pororon_good" >> ./score.txt
	# 		echo "pororon_bad=$pororon_bad" >> ./score.txt
	# 		echo "kiki_good=$kiki_good" >> ./score.txt
	# 		echo "kiki_bad=$kiki_bad" >> ./score.txt
	# 		echo "lucky_item=$lucky_item" >> ./score.txt
	# 		echo "pororon_egg=$pororon_egg" >> ./score.txt
	# 		echo "kiki_egg=🥚" >> ./score.txt
	# 	fi
	# 	egg_count_kiki=$egg_count_kiki
	# fi

	# if [[ "$2" != "roulette" ]]; then
	# 	if [[ $(($num % 10)) == 0 ]]; then
	# 		10times_pint=$(($10times_pint + 5))
	# 		echo
	# 		echo -e "\e[35m$num個目ボーナス!\e[m"
	# 		echo
	# 	fi

	# 	if [[ $(($num % 10)) == 1 ]] && [[ $num != 1 ]]; then
	# 		11times_point=$(($11times_point + 6))
	# 		echo
	# 		echo -e "\e[35m残念、$num個目アンラッキー!\e[m"
	# 		echo
	# 	fi

		# first_check=`grep "$slot_result" all_pair_history.txt`

		# if [[ "$first_check" == "" ]]; then
		# 	count_plus=$(($count_plus + 1))
		# 	echo
		# 	echo "FIRST TIME🎉 $slot_result 🎉"
		# 	echo
		# fi
	# fi

	if [[ "${player_goods[$player_num]} ${player_goods[$player_num]} ${player_goods[$player_num]}" == "$slot_result" ]]; then
		good_point=$(($good_point + 5))
		echo "$playerの好きなものです😍"
		echo
	fi
	
	if [[ "${player_bads[$player_num]} ${player_bads[$player_num]} ${player_bads[$player_num]}" == "$slot_result" ]]; then
		bad_point=$(($bad_point + 5))
		echo "$playerの苦手なものです🤢"
		echo
	fi

	if [[ "$slot_result" == "🍎 🍎 🍎" ]]; then
		if [[ $((RANDOM%+101)) -gt 70 ]]; then
			echo
			echo "おや、🍎の様子が・・・"
			cccc='\r👉'
			apples=("🍎" "🍏")

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

lucky_roulette() {
	
	echo 
	echo -e "\e[34mラッキールーレット👼\e[m"
	read -p "$playerさんはEnterを押してルーレットを回しください。"
	
	aaaa='\r👉'	
	new_array=(👼 🐵 👼 🐵 ${item_array[@]} ${item_array[@]} ${item_array[@]})
	for y in {1..50}
	do
		lucky_roulette_item=${new_array[$(($RANDOM % ${#new_array[*]}))]}
		printf "${aaaa}$lucky_roulette_item $lucky_roulette_item $lucky_roulette_item👈"
		sleep 0.1
	done

	res="$lucky_roulette_item $lucky_roulette_item $lucky_roulette_item"
	count_point "$res" "roulette"
	echo	
}

unlucky_roulette() {
	echo 
	echo -e "\e[31mアンラッキールーレット👿\e[m"
	read -p "$playerさんはEnterを押してルーレットを回しください。"
    bad_array=(👿 🍅 🐵 ${player_bads[@]} 🍅 🐵 ${player_bads[@]} 🍅 🐵 ${player_bads[@]})
	bbbb='\r👉'

	for y in {1..50}
	do
		unlucky_roulette_item=${bad_array[$(($RANDOM % ${#bad_array[*]}))]}
		printf "${bbbb}$unlucky_roulette_item $unlucky_roulette_item $unlucky_roulette_item👈"
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