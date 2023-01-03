#!/bin/bash

# setup
shopt -s extglob lastpipe
source ./array.txt
source ./score.txt
source ./pair_count.sh
source ./selector.sh

x=1
fever_flag="false"
rand_flag="false"
random_test="true"
array=(`echo "${original_array[@]} ${original_array[@]} ${original_array[@]} 🐵"`)

# =================================================

# hello
hello() {

	HELLO=`echo "${array[$(($RANDOM % ${#array[*]}))]} ${array[$(($RANDOM % ${#array[*]}))]} ${array[$(($RANDOM % ${#array[*]}))]}"`
	
	prev_pair=`cat ./prev_pair.txt`

	first_value=`echo "$HELLO" | awk '{print $1}'`
	second_value=`echo "$HELLO" | awk '{print $2}'`
	third_value=`echo "$HELLO" | awk '{print $3}'`
	

	if [[ "$prev_pair" == "$HELLO" ]]; then
		echo -e "\e[31m$slot_count: $HELLO Too much... 🤢 🤢 🤢\e[m"
		successive_flag="true"
		count_point "$HELLO"
		if [[ $(($num % 10)) == 0 ]]; then
			change_bonus_flag="true"
			change_bonus
		fi
		sed -i "2s/^//" ./all_pair_history.txt
		sed -i "3s/^/${num}: $player:$HELLO\n/" ./all_pair_history.txt	
		num=$(($num + 1))
		
	elif [ "$first_value" == "$second_value" -a "$first_value" == "$third_value" ]; then

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
		count_plus=$(($count_plus + 1))
	fi

	if [[ "$LUCKY_FOOD $LUCKY_FOOD $LUCKY_FOOD" == "$check_hello" ]]; then
		count_plus=$(($count_plus + 10))
	fi

	if [[ "$check_hello" == "🍅 🍅 🍅" ]]; then
		count_minus=$(($count_minus + 4))
	fi

	if [[ "$check_hello" == "🐵 🐵 🐵" ]]; then
		count_minus=$(($count_minus + 11))
		for monkey in `seq 1 ${LINES}`
		do
			echo -e "\e[35m🐵 🐵 🐵 🐵 🐵 🐵 🐵 🐵 🐵 🐵\e[m"
		done
	fi

	if [[ "$2" != "roulette" ]]; then
		if [[ $(($num % 10)) == 0 ]] && [[ $(($num % 15)) != 0 ]]; then
			count_plus=$(($count_plus + 5))
			echo
			echo -e "\e[35m$num個目ボーナス!\e[m"
			echo
		fi

		if [[ $(($num % 15)) == 0 ]]; then
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

}

# =================================================

lucky_roulette() {
	bbbb='\r👉'
	echo 
	echo -e "\e[34mラッキールーレット!!\e[m"
	read -p "$playerさんEnterを押してルーレットを回しください。"
	
	for y in {1..50}
	do
		lucky_item=${array[$(($RANDOM % ${#array[*]}))]}
		printf "${bbbb}$lucky_item $lucky_item $lucky_item👈"
		sleep 0.1
	done

	res="$lucky_item $lucky_item $lucky_item"
	count_point "$res" "roulette"
}


point_add_roulette() {
	echo 
	echo -e "\e[34mボーナスタイムです!!\e[m"
	echo -e "\e[34m0 ~ 9がランダムで加算されます!\e[m"
	read -p "$playerさんEnterを押してルーレットを回しください。"

	aaaa='\r👉'

	for y in {1..50}
	do
		int=$((RANDOM%+10))
		printf "${aaaa}$int👈"
		sleep 0.1
	done
	echo "$intポイント加算されました。🎉🎉"
	point=$(($point + $int))

}
# main

player=$1
p=1

read -p "リセットしますか？ y/N: " reset

if [ "$reset" == "N" -o "$reset" == "n" ]; then
	read -p "ヒストリーカウントを入力してください。" num
	read -p "ゲーム数を入力してください。" x
	num=$(($num + 1))
	x=$(($x + 1))
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
	echo "$1は好きなものを選択してください。"
	echo_value "food_array"
	source ./selector.sh
	pororon_good="$selected_value"
	echo "$1は苦手なものを選択してください。"
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

	echo "$2は好きなものを選択してください。"
	echo_value "food_array"
	source ./selector.sh
	kiki_good="$selected_value"
	echo "$2は苦手なものを選択してください。"
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
	
	echo "original_array=(${original_array[@]})" > ./array.txt
	echo "array=(${array[@]})" >> ./array.txt
	echo "flag=true" >> ./array.txt
	echo "fever=" >> ./array.txt

fi


echo -e "\e[35m$playerの番です!\e[m"

read -p "何コイン支払いますか? " howmanytimes

while [[ $howmanytimes != ":q" ]];
do

	source ./score.txt
	slot_count=1
	playerA_point=$pororon
	playerB_point=$kiki

	count_plus=0
	count_minus=0

	if [[ -z $howmanytimes ]]; then
		# read -p "何コイン支払いますか? " howmanytimes
		howmanytimes=1
	fi

	p=$(( $(($p + 1)) % 2 ))

	if [[ $p == 0 ]]; then

		new_playerA_point=$(($playerA_point - $(($howmanytimes )) ))
		new_playerB_point=$playerB_point

		make_score_file "$1" "$2" "$new_playerA_point" "$new_playerB_point"

	elif [[ $p == 1 ]]; then 

		new_playerB_point=$(($playerB_point - $(($howmanytimes )) ))
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

	if [[ $((RANDOM%+101)) -gt 90 ]]; then
		lucky_roulette
	fi
	
	point=$(($count_plus - $count_minus))

	if [[ "$rand_flag" == "true" ]]; then
		point_add_roulette
	fi

	if [[ $p == 0 ]]; then
		new_playerB_point=$kiki
		new_playerA_point=$(( $pororon + $point ))

		make_score_file "$1" "$2" "$new_playerA_point" "$new_playerB_point"
		
		echo "$x回目" >> ./slot_history.txt
		echo "$player, try: $howmanytimes回, point: $point, total: $new_playerA_point" >> ./slot_history.txt

		player=$2

	elif [[ $p == 1 ]]; then 
		new_playerB_point=$(( $kiki + $point ))
		new_playerA_point=$pororon
	
		make_score_file "$1" "$2" "$new_playerA_point" "$new_playerB_point"
		echo "$player, try: $howmanytimes回, point: $point, total: $new_playerB_point" >> ./slot_history.txt
		echo "" >> ./slot_history.txt
		x=$(($x + 1))
		rand_flag="false"
		player=$1
		
		if [[ $((RANDOM%+101)) -gt 90 ]]; then
			rand_flag="true"
		fi
		
		if [[ $fever_flag == true ]]; then
			if [[ $((RANDOM%+101)) -gt 70 ]]; then
				fever_flag="false"
				echo 
				echo -e "\e[34mフィーバータイム終了です!!\e[m"
			fi

		elif [[ $((RANDOM%+101)) -gt 90 ]]; then
			fever_flag="true"
			echo 
			echo -e "\e[34mフィーバータイムです!!\e[m"
			echo -e "\e[34m通常のポイント+1されます!!\e[m"
		fi

		if [[ $((RANDOM%+101)) -gt 70 ]]; then
			add_food
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
	
	read -p "何コイン支払いますか? " howmanytimes

done

echo "Finish!!"

# =================================================
