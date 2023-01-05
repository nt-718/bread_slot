#!/bin/bash

# setup
shopt -s extglob lastpipe
source ./array.txt
source ./score.txt
source ./pair_count.sh
source ./selector.sh

x=1
fever_flag="false"
tomato_fes_flag="false"
random_test="true"
bad_apple="false"
free_flag="false"
playerA_change_preference_flag="true"
playerB_change_preference_flag="true"
successive_count=0
devil_flag="false"
angel_flag="false"
egg_count_pororon=0
egg_count_kiki=0
egg_point_pororon=0
egg_point_kiki=0

# =================================================

# hello
hello() {

	HELLO=`echo "${array[$(($RANDOM % ${#array[*]}))]} ${array[$(($RANDOM % ${#array[*]}))]} ${array[$(($RANDOM % ${#array[*]}))]}"`
	
	prev_pair=`cat ./prev_pair.txt`
	first_value=`echo "$HELLO" | awk '{print $1}'`
	second_value=`echo "$HELLO" | awk '{print $2}'`
	third_value=`echo "$HELLO" | awk '{print $3}'`

	if [[ "$prev_pair" == "$HELLO" ]]; then
		if [[ "$tomato_fes_flag" == true ]]; then
			HELLO="🍅 🍅 🍅"
		fi

		if [[ "$angel_flag" == "$player" ]]; then

			if [[ "$player" == "pororon" ]]; then
				HELLO="$pororon_good $pororon_good $pororon_good"

			elif [[ "$player" == "kiki" ]]; then
				HELLO="$kiki_good $kiki_good $kiki_good"
			fi
		fi

		if [[ "$slot_count" == 1 ]] || [[ "$(($slot_count % 100))" == 0 ]]; then
			echo "Just $slot_count times!!"
		fi

		echo -e "\e[31m$slot_count: $HELLO Too much... 🤢 🤢 🤢\e[m"
		successive_flag="true"
		successive_count=$(($successive_count + 1))
		count_point "$HELLO"
		if [[ $(($num % 10)) == 0 ]]; then
			change_bonus_flag="true"
			change_bonus
		fi
		sed -i "2s/^//" ./all_pair_history.txt
		sed -i "3s/^/${num}: $player:$HELLO\n/" ./all_pair_history.txt	
		num=$(($num + 1))
		
	elif [ "$first_value" == "$second_value" -a "$first_value" == "$third_value" ]; then
		
		if [[ "$tomato_fes_flag" == true ]]; then
			HELLO="🍅 🍅 🍅"
		fi

		if [[ "$angel_flag" == "$player" ]]; then

			if [[ "$player" == "pororon" ]]; then
				HELLO="$pororon_good $pororon_good $pororon_good"
					
			elif [[ "$player" == "kiki" ]]; then
				HELLO="$kiki_good $kiki_good $kiki_good"
			fi
		fi
		
		if [[ "$slot_count" == 1 ]] || [[ "$(($slot_count % 100))" == 0 ]]; then
			echo "Just $slot_count times!!"
		fi

		successive_count=0
		
		echo -e "\e[33m$slot_count: $HELLO Delisious! 😋 😋 😋\e[m"
		count_point "$HELLO"
		if [[ $(($num % 10)) == 0 ]]; then
			change_bonus_flag="true"
			change_bonus
		fi

		echo "$HELLO" > ./prev_pair.txt
		sed -i "2s/^//" ./all_pair_history.txt
		sed -i "3s/^/${num}: $player:$HELLO\n/" ./all_pair_history.txt
		num=$(($num + 1))
	
	else
		echo "$slot_count: $HELLO"
	fi

	successive_flag="false"
	slot_count=$(($slot_count + 1))
}

# =================================================


# change bonus

change_bonus() {
	if [[ $change_bonus_flag == true ]]; then
        		
		lucky_item=${array[$(($RANDOM % ${#array[*]}))]}
		echo "LUCKY_FOOD="$lucky_item"" >> ./score.txt
		echo "pororon_egg=$pororon_egg" >> ./score.txt
		echo "kiki_egg=$kiki_egg" >> ./score.txt
		echo "✨ラッキーアイテムが変わりました!!✨"
	fi

	change_bonus_flag="false"
	source ./score.txt
}

# count point
count_point() {

	check_hello=$1

	count_plus=$(($count_plus + 1))

	if [[ "$fever_flag" == "true" ]]; then
		count_plus=$(($count_plus + 1))
	fi

	if [[ "$successive_flag" == "true" ]]; then
		count_plus=$(($count_plus + $successive_count))
	fi

	if [[ "$LUCKY_FOOD $LUCKY_FOOD $LUCKY_FOOD" == "$check_hello" ]]; then
		count_plus=$(($count_plus + 10))
	fi

	if [[ "$check_hello" == "🍅 🍅 🍅" ]]; then
		count_minus=$(($count_minus + 4))
	fi

	if [[ "$check_hello" == "👿 👿 👿" ]]; then
		
		echo
		for monkey in `seq 1 ${LINES}`
		do
			echo -e "\e[35m👿 👿 👿 👿 👿 👿 👿 👿 👿 👿\e[m"
			sleep 0.1
		done
		echo "ポイントが0になりました。"
		devil_flag="true"
	fi

	if [[ "$check_hello" == "👼 👼 👼" ]]; then
		
		echo
		for monkey in `seq 1 ${LINES}`
		do
			echo -e "\e[35m👼 👼 👼 👼 👼 👼 👼 👼 👼 👼\e[m"
			sleep 0.1
		done
		echo "次のターン揃ったものはすべて好物になります。"
		angel_flag="$player"
		angel_count="$x"
	fi

	if [[ "$check_hello" == "🐵 🐵 🐵" ]]; then
		count_minus=$(($count_minus + 11))
		echo
		for monkey in `seq 1 ${LINES}`
		do
			echo -e "\e[35m🐵 🐵 🐵 🐵 🐵 🐵 🐵 🐵 🐵 🐵\e[m"
			sleep 0.1
		done
	fi

	if [[ "$check_hello" == "🥚 🥚 🥚" ]]; then
		echo
		echo "🥚を獲得した！"
		echo

		if [[ "$player" == "pororon" ]] && [[ "$egg_count_pororon" == 0 ]]; then
			egg_count_pororon=1

			echo "pororon=$pororon" > ./score.txt
			echo "kiki=$kiki" >> ./score.txt
			echo "pororon_good=$pororon_good" >> ./score.txt
			echo "pororon_bad=$pororon_bad" >> ./score.txt
			echo "kiki_good=$kiki_good" >> ./score.txt
			echo "kiki_bad=$kiki_bad" >> ./score.txt
			echo "LUCKY_FOOD=$LUCKY_FOOD" >> ./score.txt
			echo "pororon_egg=🥚" >> ./score.txt
			echo "kiki_egg=$kiki_egg" >> ./score.txt
		fi

		if [[ "$player" == "kiki" ]] && [[ "$egg_count_kiki" == 0 ]]; then
			egg_count_kiki=1

			echo "pororon=$pororon" > ./score.txt
			echo "kiki=$kiki" >> ./score.txt
			echo "pororon_good=$pororon_good" >> ./score.txt
			echo "pororon_bad=$pororon_bad" >> ./score.txt
			echo "kiki_good=$kiki_good" >> ./score.txt
			echo "kiki_bad=$kiki_bad" >> ./score.txt
			echo "LUCKY_FOOD=$LUCKY_FOOD" >> ./score.txt
			echo "pororon_egg=$pororon_egg" >> ./score.txt
			echo "kiki_egg=🥚" >> ./score.txt
		fi
	fi

	if [[ "$2" != "roulette" ]]; then
		if [[ $(($num % 10)) == 0 ]]; then
			count_plus=$(($count_plus + 5))
			echo
			echo -e "\e[35m$num個目ボーナス!\e[m"
			echo
		fi

		if [[ $(($num % 10)) == 1 ]] && [[ $num != 1 ]]; then
			count_minus=$(($count_minus + 6))
			echo
			echo -e "\e[35m残念、$num個目アンラッキー!\e[m"
			echo
		fi

		first_check=`grep "$check_hello" all_pair_history.txt`

		if [[ "$first_check" == "" ]]; then
			count_plus=$(($count_plus + 1))
			echo
			echo "FIRST TIME🎉 $check_hello 🎉"
			echo
		fi
	fi


	if [[ "$player" == "pororon" ]]; then
		if [[ "$pororon_good $pororon_good $pororon_good" == "$check_hello" ]]; then
			count_plus=$(($count_plus + 4))
		fi
		
		if [[ "$pororon_bad $pororon_bad $pororon_bad" == "$check_hello" ]]; then
			count_minus=$(($count_minus + 6))
		fi
	fi
	
	if [[ "$player" == "kiki" ]]; then
		if [[ "$kiki_good $kiki_good $kiki_good" == "$check_hello" ]]; then
			count_plus=$(($count_plus + 4))
		fi

		if [[ "$kiki_bad $kiki_bad $kiki_bad" == "$check_hello" ]]; then 
			count_minus=$(($count_minus + 6))
		fi
	fi

	if [[ "$check_hello" == "🍎 🍎 🍎" ]]; then
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
				read Wait
				bad_apple="true"
			else
				echo "何にも起こらなかった・・・"
			fi
		fi
	fi

}

# make score file
make_score_file() {

	echo "$1=$3" > ./score.txt
	echo "$2=$4" >> ./score.txt
	echo "" >> ./score.txt
	echo "$1_good=$pororon_good" >> ./score.txt
	echo "$1_bad=$pororon_bad" >> ./score.txt
	echo "" >> ./score.txt
	echo "$2_good=$kiki_good" >> ./score.txt
	echo "$2_bad=$kiki_bad" >> ./score.txt
	echo >> ./score.txt
	echo "LUCKY_FOOD="$LUCKY_FOOD"" >> ./score.txt
	echo "pororon_egg=$pororon_egg" >> ./score.txt
	echo "kiki_egg=$kiki_egg" >> ./score.txt

}

# =================================================


# unlucky_roulette

lucky_roulette() {
	
	echo 
	echo -e "\e[34mラッキールーレット!!\e[m"
	read -p "$playerさんはEnterを押してルーレットを回しください。"
	
	aaaa='\r👉'	
	new_array=(👼 🐵 👼 🐵 ${original_array[@]} ${original_array[@]} ${original_array[@]})
	for y in {1..50}
	do
		lucky_item=${new_array[$(($RANDOM % ${#new_array[*]}))]}
		printf "${aaaa}$lucky_item $lucky_item $lucky_item👈"
		sleep 0.1
	done

	res="$lucky_item $lucky_item $lucky_item"
	count_point "$res" "roulette"
	echo
	
}

# ==================================================

# unlucky_roulette

unlucky_roulette() {
	echo 
	echo -e "\e[31mアンラッキールーレット👿\e[m"
	read -p "$playerさんはEnterを押してルーレットを回しください。"
    bad_array=("👿" "🍅" "🐵" "$pororon_bad" "$kiki_bad" "🍅" "🐵" "$pororon_bad" "$kiki_bad" "🍅" "🐵" "$pororon_bad" "$kiki_bad")
	bbbb='\r👉'

	for y in {1..50}
	do
		unlucky_item=${bad_array[$(($RANDOM % ${#bad_array[*]}))]}
		printf "${bbbb}$unlucky_item $unlucky_item $unlucky_item👈"
		sleep 0.1
	done

	res="$unlucky_item $unlucky_item $unlucky_item"
	count_point "$res" "roulette"
	echo

}

# ==================================================

# main

player=$1
p=1

read -p "リセットしますか？ y/N: " reset

if [ "$reset" == "N" -o "$reset" == "n" ]; then
	x=`cat slot_history.txt | grep 回目 | wc -l`
	num=`cat all_pair_history.txt | grep : | wc -l`
	x=$(($x + 1))
	num=$(($num + 1))
	pororon_good=$pororon_good
	pororon_bad=$pororon_bad
	kiki_good=$kiki_good
	kiki_bad=$kiki_bad

else
	echo "$1=10" > ./score.txt
	echo "$2=10" >> ./score.txt
	echo "HISTORY" > ./all_pair_history.txt
	echo "" >> ./all_pair_history.txt
	echo "" >> ./all_pair_history.txt
	echo "HISTORY" > ./slot_history.txt
	num=1

	read -p "ゲーム数を決めてください: " game_set
	if [[ -z $game_set ]]; then
		game_set=20

 	elif [[ "$game_set" =~ ^[0-9]+$ ]]; then
		game_set=$game_set
	else
		game_set=20
	fi
	echo "$game_setゲームで終了します。"

	clear
	echo "$1は好きなものを選択してください。"
	echo_value "food_array"
	source ./selector.sh
	pororon_good="$selected_value"
	clear
	echo -e "$1は\e[31m苦手なもの\e[mを選択してください。"
	echo_value "food_array"
	source ./selector.sh
	pororon_bad="$selected_value"

	[[ $pororon_good == "" ]] && pororon_good=${original_array[$(($RANDOM % ${#original_array[*]}))]}
	[[ $pororon_bad == "" ]] && pororon_bad=${original_array[$(($RANDOM % ${#original_array[*]}))]}
	
	while [[ $random_test == "true" ]]
	do
		if [[ "$pororon_bad" == "$pororon_good" ]]; then
			pororon_bad=${original_array[$(($RANDOM % ${#original_array[*]}))]}
		else
			pororon_bad=$pororon_bad
			random_test="false"
		fi
	done

	random_test="true"

	echo "" >> ./score.txt
	echo
	echo "$1_good=$pororon_good" >> ./score.txt
	echo "$1_bad=$pororon_bad" >> ./score.txt

	clear
	echo "$2は好きなものを選択してください。"
	echo_value "food_array"
	source ./selector.sh
	kiki_good="$selected_value"
	clear
	echo -e "$2は\e[31m苦手なもの\e[mを選択してください。"
	echo_value "food_array"
	source ./selector.sh
	kiki_bad="$selected_value"
	
	[[ $kiki_good == "" ]] && kiki_good=${original_array[$(($RANDOM % ${#original_array[*]}))]}
	[[ $kiki_bad == "" ]] && kiki_bad=${original_array[$(($RANDOM % ${#original_array[*]}))]}
	
	while [[ $random_test == "true" ]]
	do
		if [[ "$kiki_bad" == "$kiki_good" ]]; then
			kiki_bad=${original_array[$(($RANDOM % ${#original_array[*]}))]}
		else
			kiki_bad=$kiki_bad
			random_test="false"
		fi
	done

	echo "" >> ./score.txt
	echo
	echo "$2_good=$kiki_good" >> ./score.txt
	echo "$2_bad=$kiki_bad" >> ./score.txt
	echo >> ./score.txt
	echo "LUCKY_FOOD=" >> ./score.txt
	echo "pororon_egg=" >> ./score.txt
	echo "kiki_egg=" >> ./score.txt
	
	array=(`echo "${original_array[@]} ${original_array[@]} ${original_array[@]} 🐵"`)
	echo "original_array=(${original_array[@]})" > ./array.txt
	echo "array=(${array[@]})" >> ./array.txt
	echo "fever=" >> ./array.txt

fi

echo -e "\e[35m$playerの番です!\e[m"

read -p "何コイン使いますか? " howmanytimes

while [[ $howmanytimes != ":q" ]];
do
	source ./score.txt
	slot_count=1
	playerA_point=$pororon
	playerB_point=$kiki

	count_plus=0
	count_minus=0
	
	if [[ "$howmanytimes" == "change" ]]; then

		if [[ "$player" == "$1" ]] && [[ "$playerA_change_preference_flag" == "false" ]]; then
			echo "2度目の変更はできません。"
		elif [[ "$player" == "$1" ]]; then
			clear
			echo "$playerの好みを変更します。"
			echo "$playerは好きなものを選択してください。"
			echo_value "food_array"
			source ./selector.sh
			pororon_good="$selected_value"

			echo "$playerは苦手なものを選択してください。"
			echo_value "food_array"
			source ./selector.sh
			pororon_bad="$selected_value"
			[[ $pororon_good == "" ]] && pororon_good=${original_array[$(($RANDOM % ${#original_array[*]}))]}
			[[ $pororon_bad == "" ]] && pororon_bad=${original_array[$(($RANDOM % ${#original_array[*]}))]}
	
			random_test="true"
			while [[ $random_test == "true" ]]
			do
				if [[ "$pororon_bad" == "$pororon_good" ]]; then
					pororon_bad=${original_array[$(($RANDOM % ${#original_array[*]}))]}
				else
					pororon_bad=$pororon_bad
					random_test="false"
				fi
			done

			echo "$1=$pororon" > ./score.txt
			echo "$2=$kiki" >> ./score.txt
			echo "$1_good=$pororon_good" >> ./score.txt
			echo "$1_bad=$pororon_bad" >> ./score.txt
			echo "$2_good=$kiki_good" >> ./score.txt
			echo "$2_bad=$kiki_bad" >> ./score.txt
			echo >> ./score.txt
			echo "LUCKY_FOOD=$LUCKY_FOOD" >> ./score.txt
			echo "pororon_egg=$pororon_egg" >> ./score.txt
			echo "kiki_egg=$kiki_egg" >> ./score.txt

			echo "$playerの好みが変更されました"
			playerA_change_preference_flag="false"
			read -p "何コイン使いますか? " howmanytimes
		fi

		if [[ "$player" == "$2" ]] && [[ "$playerB_change_preference_flag" == "false" ]]; then
			echo "2度目の変更はできません。"
		elif [[ "$player" == "$2" ]]; then
			clear
			echo "$playerの好みを変更します。"
			echo "$playerは好きなものを選択してください。"
			echo_value "food_array"
			source ./selector.sh			
			kiki_good="$selected_value"
			
			echo "$playerは苦手なものを選択してください。"
			echo_value "food_array"
			source ./selector.sh
			kiki_bad="$selected_value"

			[[ $kiki_good == "" ]] && kiki_good=${original_array[$(($RANDOM % ${#original_array[*]}))]}
			[[ $kiki_bad == "" ]] && kiki_bad=${original_array[$(($RANDOM % ${#original_array[*]}))]}
			
			random_test="true"
			while [[ $random_test == "true" ]]
			do
				if [[ "$kiki_bad" == "$kiki_good" ]]; then
					kiki_bad=${original_array[$(($RANDOM % ${#original_array[*]}))]}
				else
					kiki_bad=$kiki_bad
					random_test="false"
				fi
			done

			echo "$1=$pororon" > ./score.txt
			echo "$2=$kiki" >> ./score.txt
			echo "$1_good=$pororon_good" >> ./score.txt
			echo "$1_bad=$pororon_bad" >> ./score.txt
			echo "$2_good=$kiki_good" >> ./score.txt
			echo "$2_bad=$kiki_bad" >> ./score.txt
			echo >> ./score.txt
			echo "LUCKY_FOOD=$LUCKY_FOOD" >> ./score.txt
			echo "pororon_egg=$pororon_egg" >> ./score.txt
			echo "kiki_egg=$kiki_egg" >> ./score.txt
			
			echo "$playerの好みが変更されました"
			playerB_change_preference_flag="false"
			read -p "何コイン使いますか? " howmanytimes
		fi	
		
	fi

	if [[ -z $howmanytimes ]]; then
		howmanytimes=1
 	elif [[ "$howmanytimes" =~ ^[0-9]+$ ]]; then
		howmanytimes=$howmanytimes
	else
		howmanytimes=1
	fi

	p=$(( $(($p + 1)) % 2 ))

	if [[ $p == 0 ]]; then


		if [[ "$free_flag" == "true" ]]; then
			new_playerA_point=$playerA_point
			free_flag="false"
		else
			new_playerA_point=$(($playerA_point - $(($howmanytimes )) ))
		fi

		new_playerB_point=$playerB_point

		make_score_file "$1" "$2" "$new_playerA_point" "$new_playerB_point"

	elif [[ $p == 1 ]]; then 

		if [[ "$free_flag" == "true" ]]; then
			new_playerB_point=$playerB_point
			free_flag="false"
		else
			new_playerB_point=$(($playerB_point - $(($howmanytimes )) ))
		fi

		new_playerA_point=$playerA_point

		make_score_file "$1" "$2" "$new_playerA_point" "$new_playerB_point"

	fi
	
	howmanytimes=$(($howmanytimes * 100))

	for i in `seq 1 $howmanytimes`;
	do
		hello
		sleep 0.07
	done

	source ./score.txt

	if [[ $((RANDOM%+101)) -gt 80 ]]; then
		lucky_roulette
	fi

	if [[ $((RANDOM%+101)) -gt 95 ]]; then
		unlucky_roulette
	fi

	if [[ "$bad_apple" == "true" ]]; then
		count_plus=0
		bad_apple="false"
	fi

	if [[ "$player" == "pororon" ]] && [[ "$egg_count_pororon" != 0 ]]; then
		egg_count_pororon=$(($egg_count_pororon + 1))
	fi

	if [[ "$player" == "kiki" ]] && [[ "$egg_count_kiki" != 0 ]]; then
		egg_count_kiki=$(($egg_count_kiki + 1))
	fi

	if [[ "$player" == "pororon" ]] && [[ "$egg_count_pororon" == 4 ]]; then
		
		if [[ $((RANDOM%+101)) -gt 95 ]]; then
			echo
			echo "🥚から👼が生まれました！！"
			count_point "👼 👼 👼"
			egg_point_pororon=0

		elif [[ $((RANDOM%+101)) -gt 50 ]]; then
			echo
			echo "🥚が孵化して🐣になりました！！"
			echo "毎ターン+1ポイントされます。"
			echo
			egg_point_pororon=1
			pororon_egg="🐣"
			kiki_egg=$kiki_egg

		else
			echo
			echo "🥚の孵化に失敗しました。"
			echo
			egg_point_pororon=0
			egg_count_pororon=0
			pororon_egg=""
			kiki_egg=$kiki_egg
		fi
	fi

	if [[ "$player" == "kiki" ]] && [[ "$egg_count_kiki" == 4 ]]; then
		if [[ $((RANDOM%+101)) -gt 95 ]]; then
			echo
			echo "🥚から👼が生まれました！！"
			count_point "👼 👼 👼"
			egg_point_kiki=0
		elif [[ $((RANDOM%+101)) -gt 50 ]]; then
			echo
			echo "🥚が孵化して🐣になりました！！"
			echo "毎ターン+1ポイントされます。"
			echo
			egg_point_kiki=1
			pororon_egg=$pororon_egg
			kiki_egg="🐣"

		else
			echo
			echo "🥚の孵化に失敗しました。"
			echo
			egg_point_kiki=0
			egg_count_kiki=0
			pororon_egg=$pororon_egg
			kiki_egg=""

		fi	
	fi

	if [[ "$player" == "pororon" ]] && [[ "$egg_count_pororon" == 7 ]]; then
		if [[ $((RANDOM%+101)) -gt 50 ]]; then
			echo
			echo "🐣が成長して🐥になりました！！"
			echo "毎ターン+2ポイントされます。"
			echo
			egg_point_pororon=2
			pororon_egg="🐥"
			kiki_egg=$kiki_egg

		else
			echo
			echo "🐣が息を引き取りました。"
			echo
			egg_point_pororon=0
			egg_count_pororon=0
			pororon_egg=""
			kiki_egg=$kiki_egg

		fi	
	fi

	if [[ "$player" == "kiki" ]] && [[ "$egg_count_kiki" == 7 ]]; then
		if [[ $((RANDOM%+101)) -gt 50 ]]; then
			echo
			echo "🐣が成長して🐥になりました！！"
			echo "毎ターン+2ポイントされます。"
			echo
			egg_point_kiki=2
			pororon_egg=$pororon_egg
			kiki_egg="🐥"

		else
			echo
			echo "🐣が息を引き取りました。"
			echo
			egg_point_kiki=0
			egg_count_kiki=0
			pororon_egg=$pororon_egg
			kiki_egg=""

		fi	
	fi

	if [[ "$player" == "pororon" ]] && [[ "$egg_count_pororon" == 10 ]]; then
		if [[ $((RANDOM%+101)) -gt 50 ]]; then
			echo
			echo "🐥が成長して🐔になりました！！"
			echo "毎ターン+3ポイントされます。"
			echo
			egg_point_pororon=3
			pororon_egg="🐔"
			kiki_egg=$kiki_egg

		else
			echo
			echo "🐥が息を引き取りました。"
			echo
			egg_point_pororon=0
			egg_count_pororon=0
			pororon_egg=""
			kiki_egg=$kiki_egg
		fi	
	fi

	if [[ "$player" == "kiki" ]] && [[ "$egg_count_kiki" == 10 ]]; then
		if [[ $((RANDOM%+101)) -gt 50 ]]; then
			echo
			echo "🐥が成長して🐔になりました！！"
			echo "毎ターン+3ポイントされます。"
			echo
			egg_point_kiki=3
			pororon_egg=$pororon_egg
			kiki_egg="🐔"

			echo "pororon_egg=$pororon_egg" >> ./score.txt
			echo "kiki_egg=🐔" >> ./score.txt
		else
			echo
			echo "🐥が息を引き取りました。"
			echo
			egg_point_kiki=0
			egg_count_kiki=0
			pororon_egg=$pororon_egg
			kiki_egg=""
		fi	
	fi

	if [[ "$player" == "pororon" ]] && [[ "$egg_count_pororon" == 13 ]]; then
		echo
		echo "🐔が息を引き取りました。"
		echo "毎ターンのポイント加算が終了します。"
		echo
		egg_point_pororon=0
		egg_count_pororon=0
		pororon_egg=""
		kiki_egg=$kiki_egg
	fi

	if [[ "$player" == "kiki" ]] && [[ "$egg_count_kiki" == 13 ]]; then
		echo
		echo "🐔が息を引き取りました。"
		echo "毎ターンのポイント加算が終了します。"
		echo
		egg_point_kiki=0
		egg_count_kiki=0
		pororon_egg=$pororon_egg
		kiki_egg=""
	fi

	point=$(($count_plus - $count_minus))

	
	if [[ "$angel_flag" == "$player" ]] && [[ "$x" != "$angel_count" ]]; then
		angel_flag="false"
	fi

	if [[ $p == 0 ]]; then
		new_playerB_point=$kiki
		new_playerA_point=$(( $pororon + $point + $egg_point_pororon ))

		if [[ $devil_flag == "true" ]]; then
			new_playerA_point=0
			$devil_flag == "false"
		fi

		make_score_file "$1" "$2" "$new_playerA_point" "$new_playerB_point"
		
		echo "$x回目" >> ./slot_history.txt
		echo "$player, try: $howmanytimes回, point: $point, total: $new_playerA_point" >> ./slot_history.txt

		player=$2

	elif [[ $p == 1 ]]; then 
		new_playerB_point=$(( $kiki + $point + $egg_point_kiki ))
		if [[ $devil_flag == "true" ]]; then
			new_playerB_point=0
			$devil_flag == "false"
		fi
		new_playerA_point=$pororon
	
		make_score_file "$1" "$2" "$new_playerA_point" "$new_playerB_point"
		echo "$player, try: $howmanytimes回, point: $point, total: $new_playerB_point" >> ./slot_history.txt
		echo "" >> ./slot_history.txt

		if [[ $(($x % 10)) == 0 ]]; then
			echo "$x回目が終了しました。"
		fi

		if [[ $(($x % 5)) == 0 ]]; then
			add_food
		fi

		x=$(($x + 1))
		player=$1
		
		if [[ $tomato_fes_flag == "true" ]]; then
			tomato_fes_flag="false"
			echo "🍅FESTIVALが終了しました。🍅"

		elif [[ $((RANDOM%+101)) -gt 85 ]]; then
			tomato_fes_flag="true"
			echo
			echo "🍅🍅🍅 FESTIVAL 🍅🍅🍅"
			echo "次のターン、揃ったものはすべて🍅になります。"
			echo "連続ポイントは加算されません。"
		fi
		
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

	fi

	echo
	echo "$pointポイント"

	echo 
	if [[ $fever_flag == true ]]; then
		echo -e "\e[34mフィーバー中です!!\e[m"
	fi

	if [[ "$player" == "$1" ]]; then
		echo -e "\e[35m次は$playerの番です!\e[m"
	else
		echo -e "\e[36m次は$playerの番です!\e[m"
	fi
	
	if [[ $((RANDOM%+101)) -gt 80 ]]; then
		free_flag="true"
		echo ""
		echo "💸フリータイムです！！💸"
		echo "💸このターンは無料で回せます！！💸"
		echo ""
	fi

	if [[ "$x" == "$(($game_set + 1))" ]]; then
		echo "Finish!!"
		echo
		echo "pororon: $pororon vs kiki: $kiki"
		echo
		
		echo "勝者は・・・"
		read -p "Enterを押してください"

		if [[ $pororon < $kiki ]]; then
			echo "👏 Winner 🎉kiki🎉 👏"
		elif [[ $pororon > $kiki ]]; then
			echo "👏 Winner 🎉pororon🎉 👏"
		else
			echo "Draw"
		fi

		break
	fi

	read -p "何コイン使いますか? " howmanytimes

done

echo "Finish!!"

# =================================================
