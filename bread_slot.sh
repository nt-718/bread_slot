#!/bin/bash

# setup
shopt -s extglob lastpipe
source ./array.txt
source ./score.txt
x=1

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
		echo "✨LUCKY ITEM CHANGED!!✨"
	fi

	change_bonus_flag="false"
	source ./score.txt
}

# count point
count_point() {

	check_hello=$1

	if [[ "$successive_flag" == "true" ]]; then
		count_plus=$(($count_plus + 2))
	else
		count_plus=$(($count_plus + 1))
	fi

	if [[ "$LUCKY_FOOD $LUCKY_FOOD $LUCKY_FOOD" == "$check_hello" ]]; then
		count_plus=$(($count_plus + 10))
	fi

	if [[ "$check_hello" == "🍅 🍅 🍅" ]]; then
		count_minus=$(($count_minus + 4))
	fi

	if [[ $(($num % 10)) == 0 ]] && [[ $(($num % 15)) != 0 ]]; then
		count_plus=$(($count_plus + 5))
	fi

	if [[ $(($num % 15)) == 0 ]]; then
		count_minus=$(($count_minus + 6))
	fi

	first_check=`grep "$check_hello" all_pair_history.txt`

	if [[ "$first_check" == "" ]]; then
		count_plus=$(($count_plus + 1))
		echo "FIRST TIME🎉"
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

# main

player=$1
p=1

read -p "リセットしますか？ y/N: " reset

if [ $reset == "N" -o $reset == "n" ]; then
	read -p "カウントを入力してください。" num
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
	echo "$1のあたりとはずれを選択してください。"
	read -p ">> " pororon_good pororon_bad
	echo "" >> ./score.txt
	echo
	echo "$1_good=$pororon_good" >> ./score.txt
	echo "$1_bad=$pororon_bad" >> ./score.txt
	echo "$2のあたりとはずれを選択してください。"
	read -p ">> " kiki_good kiki_bad
	echo "" >> ./score.txt
	echo
	echo "$2_good=$kiki_good" >> ./score.txt
	echo "$2_bad=$kiki_bad" >> ./score.txt
	echo >> ./score.txt
	echo "LUCKY_FOOD=none" >> ./score.txt

fi


echo "$playerの番です。"
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
		sleep 0.05
	done

	source ./score.txt
	
	point=$(($count_plus - $count_minus))

	if [[ $p == 0 ]]; then
		new_playerB_point=$kiki
		new_playerA_point=$(( $pororon + $count_plus - $count_minus ))

		make_score_file "$1" "$2" "$new_playerA_point" "$new_playerB_point"
		
		echo "$x回目" >> ./slot_history.txt
		echo "$player, try: $howmanytimes回, point: $point, total: $new_playerA_point" >> ./slot_history.txt

		player=$2

	elif [[ $p == 1 ]]; then 
		new_playerB_point=$(( $kiki + $count_plus - $count_minus ))
		new_playerA_point=$pororon
	
		make_score_file "$1" "$2" "$new_playerA_point" "$new_playerB_point"
		echo "$player, try: $howmanytimes回, point: $point, total: $new_playerB_point" >> ./slot_history.txt
		echo "" >> ./slot_history.txt
		x=$(($x + 1))
		player=$1
	fi
	echo
	echo "$pointポイント"


	echo 
	echo "次は$playerの番です。"
	read -p "何コイン支払いますか? " howmanytimes

done

echo "Finish!!"

# =================================================
