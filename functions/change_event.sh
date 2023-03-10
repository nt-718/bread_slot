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
        echo -e "\e[34mπγ©γγ­γΌγ’γ€γγ γ$lucky_item_to_addγ«γͺγγΎγγπ\e[m"
    fi
}

change_seasonal_item() {
    source ./db/game_history.txt
    source ./db/events.txt
    
    if [[ $(($game_count % 5)) == 0 ]] && [[ "$player" == "${players[$((${#players[@]} - 1))]}" ]]; then
        seasonal_item=${item_array_to_use[$(($RANDOM % ${#item_array_to_use[@]}))]}
        echo "item_array=(${item_array[@]})" > ./db/items.txt
        item_array_to_use=(${item_array[@]} ${item_array[@]} ${item_array[@]} π΅ $seasonal_item)
        echo "item_array_to_use=(${item_array_to_use[@]})" >> ./db/items.txt

        echo "seasonal_item=$seasonal_item" >> ./db/events.txt

        echo
        echo -e "\e[34m$seasonal_itemγ―δ»γζ¬!!\e[m"
        echo -e "\e[34mπ$seasonal_itemγεΊγγγγͺγγΎγγπ\e[m"
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
            echo -e "\e[34mγγ£γΌγγΌγΏγ€γ η΅δΊγ§γ!!\e[m"
        fi

    elif [[ $((RANDOM%+101)) -gt 80 ]]; then
        fever_flag="true"
        echo 
        echo -e "\e[34mγγ£γΌγγΌγΏγ€γ γ§γ!!\e[m"
        echo -e "\e[34mιεΈΈγ?γγ€γ³γ+1γγγΎγ!!\e[m"
    fi
}

free_time() {

	if [[ $((RANDOM%+101)) -gt 80 ]]; then
		free_flag="true"
		echo
		echo "πΈγγͺγΌγΏγ€γ γ§γοΌοΌπΈ"
		echo "πΈγγ?γΏγΌγ³γ―η‘ζγ§εγγΎγοΌοΌπΈ"
	fi
}

inflation_time() {

	if [[ $((RANDOM%+101)) -gt 80 ]]; then
		inflation_flag="true"
		echo
		echo -e "\e[34mγ€γ³γγ¬δΈ­γ§γ!!\e[m"
		echo -e "\e[34mζ―ζγ³γ€γ³γ2εγ«γͺγγΎγ\e[m"
	fi
}

tomato_festival() {
    if [[ $tomato_fes_flag == "true" ]]; then
        tomato_fes_flag="false"
        echo "πFESTIVALγη΅δΊγγΎγγγπ"

    elif [[ $((RANDOM%+101)) -gt 85 ]]; then
        tomato_fes_flag="true"
        echo
        echo "πππ FESTIVAL πππ"
        echo "ζ¬‘γ?γΏγΌγ³γζγ£γγγ?γ―γγΉγ¦πγ«γͺγγΎγγ"
        echo "ι£ηΆγγ€γ³γγ―ε η?γγγΎγγγ"
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
			echo "π₯γγπΌγηγΎγγΎγγοΌοΌ"
			count_point "πΌ πΌ πΌ"

		elif [[ $((RANDOM%+101)) -gt 50 ]]; then
			echo
			echo "π₯γε­΅εγγ¦π£γ«γͺγγΎγγοΌοΌ"
			echo "ζ―γΏγΌγ³+1γγ€γ³γγγγΎγγ"
			echo
            egg_growth

		else
			echo
			echo "π₯γ?ε­΅εγ«ε€±ζγγΎγγγ"
			echo
            egg_growth "death"

		fi

    elif [[ "${eggs[$player_num]}" == 5 ]]; then
		
        if [[ $((RANDOM%+101)) -gt 50 ]]; then
			echo
			echo "π£γζι·γγ¦π₯γ«γͺγγΎγγοΌοΌ"
			echo "ζ―γΏγΌγ³+2γγ€γ³γγγγΎγγ"
			echo
            egg_growth

		else
			echo
			echo "π£γζ―γεΌγεγγΎγγγ"
			echo
            egg_growth "death"

		fi

    elif [[ "${eggs[$player_num]}" == 7 ]]; then
		
		if [[ $((RANDOM%+101)) -gt 50 ]]; then
			echo
			echo "π₯γζι·γγ¦πγ«γͺγγΎγγοΌοΌ"
			echo "ζ―γΏγΌγ³+3γγ€γ³γγγγΎγγ"
			echo
            egg_growth

		else
			echo
			echo "π₯γζ―γεΌγεγγΎγγγ"
			echo
            egg_growth "death"

		fi
    
    elif [[ "${eggs[$player_num]}" == 10 ]]; then
		echo
		echo "πγζ―γεΌγεγγΎγγγ"
		echo "ζ―γΏγΌγ³γ?γγ€γ³γε η?γη΅δΊγγΎγγ"
		echo
        egg_growth "death"

    elif [[ "${eggs[$player_num]}" != 0 ]]; then
        egg_growth

	fi

}

random_pay() {
    
    if [[ $((RANDOM%+101)) -gt 85 ]]; then
        ghost_flag="true"
        echo
        echo "π» εΉ½ιγ?γγγγ π»"
        echo "δ½Ώη¨γγγ³γ€γ³ζ°γγ©γ³γγ γ«γͺγ£γ"
    fi
}