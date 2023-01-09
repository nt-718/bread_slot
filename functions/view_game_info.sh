#!/bin/bash

show_summary() {
	source ./db/points.txt
	source ./db/events.txt
	source ./db/game_history.txt
	source ./db/players.txt

	echo
    echo "ゲーム回数：$game_count"
    echo
	echo "$player"
	echo
	echo "+++++++++++++++++++++++"
	echo "揃った数：+$mutch_count"
    echo "連続ポイント：+$successive_point"
    echo "初揃いポイント：+$first_point"
    echo "フィーバーポイント：+$fever_point"
    echo "ラッキーポイント：+$lucky_point"
	echo "ニワトリポイント：+$egg_point"
    echo "%10=0ボーナス：+$ten_times_point"
    echo "好きなものポイント：+$good_point"
	echo "+++++++++++++++++++++++"
	echo
    echo "-----------------------"
    echo "支払コイン：-$paid_coin"
    echo "トマトペナルティ：-$tomato_point"
    echo "モンキーペナルティ：-$monkey_point"
    echo "%10=2ペナルティ：-$bad_times_point"
    echo "苦手なものペナルティ：-$bad_point"
	echo "-----------------------"
    echo
    echo "ポイント：$point"
	echo
	player_eggs=()
	for i in `seq 0 $((${#players[@]} - 1))`
    do
		if [[ ${eggs[$i]} == "0" ]]; then
			player_eggs+=("none")
		elif [[ ${eggs[$i]} != "0" ]] && [[ ${eggs[$i]} -lt "4" ]]; then
			player_eggs+=(🥚)
		elif [[ ${eggs[$i]} -gt "3" ]] && [[ ${eggs[$i]} -lt "6" ]]; then
			player_eggs+=(🐣)
		elif [[ ${eggs[$i]} -gt "5" ]] && [[ ${eggs[$i]} -lt "8" ]]; then
			player_eggs+=(🐥)
		elif [[ ${eggs[$i]} -gt "7" ]] && [[ ${eggs[$i]} -lt "10" ]]; then
			player_eggs+=(🐔)
		fi	
		echo "${players[$i]}: ${player_points[$i]} 😍${player_goods[$i]} 🤢${player_bads[$i]} ${player_eggs[$i]}"
	done

	echo
	echo "ラッキーアイテム：$lucky_item"
	echo "旬のアイテム：$seasonal_item"
}

