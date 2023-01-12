#!/bin/bash

shopt -s extglob lastpipe
source ./db/players.txt
source ./db/items.txt
source ./db/points.txt
source ./db/events.txt
source ./db/game_history.txt

change_event() {
    source ./db/events.txt
    change_seasonal_item
    echo "lucky_item=$lucky_item" > ./db/events.txt
    echo "seasonal_item=$seasonal_item" >> ./db/events.txt
	echo "eggs=(${eggs[@]})" >> ./db/events.txt
}

change_lucky_item() {
    source ./db/game_history.txt
    source ./db/events.txt
    
    count=$(cat ./db/all_pair_history.txt | grep : | wc -l)
    
    if [[ $(($count % 10)) == 0 ]]; then
        lucky_item_to_add=${item_array[$(($RANDOM % ${#item_array[@]}))]}
        echo "lucky_item=$lucky_item_to_add" >> ./db/events.txt
        echo
        echo -e "\e[34m🎉ラッキーアイテムが$lucky_item_to_addになりました🎉\e[m"
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
        if [[ $((RANDOM%+101)) -gt 50 ]]; then
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

	if [[ $((RANDOM%+101)) -gt 80 ]] && [[ "$inflation_flag" == "false" ]]; then
		free_flag="true"
		echo
		echo "💸フリータイムです！！💸"
		echo "💸このターンは無料で回せます！！💸"
	fi
}

inflation_time() {

	if [[ $((RANDOM%+101)) -gt 80 ]] && [[ "$free_flag" == "false" ]]; then
		inflation_flag="true"
		echo
		echo -e "\e[34mインフレ中です!!\e[m"
		echo -e "\e[34m支払コインが2倍になります\e[m"
	fi
}

abnormal_events() {

	if [[ $((RANDOM%+101)) -gt 99 ]]; then
        echo -e "\e[31m👿天変地異が起こった👿\e[m"
        sleep 1	

        bad_array=(👿 😈)
        bbbb='\r👉'

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
        
        if [[ $unlucky_roulette_item == 😈 ]]; then
            echo ""
            echo "😈は機嫌がよかったみたいだ"
            echo "何とか乗り切った😵"
        else
            echo "👿が怒っている！"
            echo "ポイントが半分になった😱"
            res="$unlucky_roulette_item $unlucky_roulette_item $unlucky_roulette_item"
            count_point "$res" "roulette"
            echo
        fi
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
    source ./db/events.txt
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
    source ./db/events.txt
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
            egg_growth

		else
			echo
			echo "🥚の孵化に失敗しました。"
			echo
            egg_growth "death"

		fi

    elif [[ "${eggs[$player_num]}" == 5 ]]; then
		
        if [[ $((RANDOM%+101)) -gt 50 ]]; then
			echo
			echo "🐣が成長して🐥になりました！！"
			echo "毎ターン+2ポイントされます。"
			echo
            egg_growth

		else
			echo
			echo "🐣が息を引き取りました。"
			echo
            egg_growth "death"

		fi

    elif [[ "${eggs[$player_num]}" == 7 ]]; then
		
		if [[ $((RANDOM%+101)) -gt 50 ]]; then
			echo
			echo "🐥が成長して🐔になりました！！"
			echo "毎ターン+3ポイントされます。"
			echo
            egg_growth

		else
			echo
			echo "🐥が息を引き取りました。"
			echo
            egg_growth "death"

		fi
    
    elif [[ "${eggs[$player_num]}" == 10 ]]; then
		echo
		echo "🐔が息を引き取りました。"
		echo "毎ターンのポイント加算が終了します。"
		echo
        egg_growth "death"

    elif [[ "${eggs[$player_num]}" != 0 ]]; then
        egg_growth

	fi

}

random_pay() {
    
    if [[ $((RANDOM%+101)) -gt 90 ]]; then
        ghost_flag="true"
        echo
        echo "👻 幽霊のいたずら 👻"
        echo "使用するコイン数がランダムになった"
    fi
}