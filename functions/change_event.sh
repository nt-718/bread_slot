#!/bin/bash

shopt -s extglob lastpipe
source ./db/players.txt
source ./db/items.txt
source ./db/points.txt
source ./db/events.txt
source ./db/game_history.txt

change_event() {
    source ./db/events.txt
    change_lucky_item
    change_seasonal_item
    echo "lucky_item=$lucky_item" > ./db/events.txt
    echo "seasonal_item=$seasonal_item" >> ./db/events.txt
	echo "eggs=(${eggs[@]})" >> ./db/events.txt
}

change_lucky_item() {
    source ./db/game_history.txt
    source ./db/events.txt
    
    if [[ $(($game_count % 10)) == 0 ]] && [[ "$player" == "${players[$((${#players[@]} - 1))]}" ]]; then
        lucky_item=${item_array[$(($RANDOM % ${#item_array[@]}))]}
        echo "lucky_item=$lucky_item" >> ./db/events.txt
    fi
}

change_seasonal_item() {
    source ./db/game_history.txt
    source ./db/events.txt
    
    if [[ $(($game_count % 5)) == 0 ]] && [[ "$player" == "${players[$((${#players[@]} - 1))]}" ]]; then
        seasonal_item=${item_array_to_use[$(($RANDOM % ${#item_array_to_use[@]}))]}
        echo "item_array=(${item_array[@]})" > ./db/items.txt
        item_array_to_use=(${item_array[@]} ${item_array[@]} ${item_array[@]} 🐵 $seasonal_item)
        echo "item_array_to_use=(${item_array_to_use[@]})" >> ./db/items.txt

        echo "seasonal_item=$seasonal_item" >> ./db/events.txt

        echo
        echo -e "\e[34m$seasonal_itemは今が旬!!\e[m"
        echo -e "\e[34m🎉$seasonal_itemが出やすくなりました🎉\e[m"
    fi
}

angel_event() {
	source ./db/game_history.txt

    if [[ "$angel_flag" == "$player" ]] && [[ "$game_count" != "$angel_count" ]]; then
		angel_flag=false
	fi
}

fever_time() {
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
}

free_time() {

	if [[ $((RANDOM%+101)) -gt 80 ]]; then
		free_flag="true"
		echo
		echo "💸フリータイムです！！💸"
		echo "💸このターンは無料で回せます！！💸"
	fi
}

tomato_festival() {
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
}

egg_growth() {
	new_eggs=()

    for i in `seq 0 $((${#players[@]} - 1))`
    do
        if [[ ${players[$i]} == "$player" ]]; then
            if [[ ${eggs[$i]} != 0 ]]; then
                if [[ $1 == "death" ]]; then
    				new_eggs+=(0)
                else
	    			new_eggs+=($((${eggs[$i]} + 1)))
                fi
			fi
        else
            new_eggs+=(${eggs[$i]})
        fi
    done

    echo "eggs=(${new_eggs[@]})" >> ./db/events.txt
}

egg_bonus() {
    search_name=$1
	for i in `seq 0 $((${#players[@]} - 1))`
	do
		if [[ ${players[$i]} == "$search_name" ]]; then
			player_num=$i
		fi
	done
	
    if [[ "${eggs[$player_num]}" == 3 ]]; then
		
		if [[ $((RANDOM%+101)) -gt 95 ]]; then
			echo
			echo "🥚から👼が生まれました！！"
			count_point "👼 👼 👼"

		elif [[ $((RANDOM%+101)) -gt 50 ]]; then
			echo
			echo "🥚が孵化して🐣になりました！！"
			echo "毎ターン+1ポイントされます。"
			echo
            egg_point=1
            egg_growth

		else
			echo
			echo "🥚の孵化に失敗しました。"
			echo
            egg_point=0
            egg_growth "death"

		fi

    elif [[ "${eggs[$player_num]}" == 5 ]]; then
		
        if [[ $((RANDOM%+101)) -gt 50 ]]; then
			echo
			echo "🐣が成長して🐥になりました！！"
			echo "毎ターン+2ポイントされます。"
			echo
            egg_point=2
            egg_growth

		else
			echo
			echo "🐣が息を引き取りました。"
			echo
            egg_point=0
            egg_growth "death"

		fi

    elif [[ "${eggs[$player_num]}" == 7 ]]; then
		
		if [[ $((RANDOM%+101)) -gt 50 ]]; then
			echo
			echo "🐥が成長して🐔になりました！！"
			echo "毎ターン+3ポイントされます。"
			echo
            egg_point=3
            egg_growth

		else
			echo
			echo "🐥が息を引き取りました。"
			echo
            egg_point=0
            egg_growth "death"

		fi
    
    elif [[ "${eggs[$player_num]}" == 10 ]]; then
		echo
		echo "🐔が息を引き取りました。"
		echo "毎ターンのポイント加算が終了します。"
		echo
        egg_point=0
        egg_growth "death"

    else
        egg_growth

	fi

}