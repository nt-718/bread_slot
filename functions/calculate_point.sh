#!/bin/bash

shopt -s extglob lastpipe
source ./db/players.txt
source ./db/items.txt
source ./db/points.txt
source ./db/events.txt
source ./db/game_history.txt

calculate_point() {
    if [[ "$free_flag" == true ]]; then
        paid_coin=0
        free_flag=false
    fi
    point_plus=$(( $mutch_count + $successive_point + $fever_point + $lucky_point + $good_point + $ten_times_point + $bad_times_point))
    point_minus=$(($paid_coin + $tomato_point + $monkey_point + $bad_point ))
    if [[ $bad_apple == true ]]; then
        point_plus=0
    fi

    point=$(($point_plus - $point_minus))

}

insert_point_data() {

    source ./db/points.txt
    new_player_point=()
    for i in `seq 0 $((${#players[@]} - 1))`
    do
        if [[ ${players[$i]} == "$player" ]]; then 
            if [[ "$devil_flag" == true ]]; then
                new_player_point+=($((${player_points[$i]} / 2)))
            else
                new_player_point+=($((${player_points[$i]} + $point)))
            fi
        else
            new_player_point+=(${player_points[$i]})
        fi
    done

    echo "player_points=(${new_player_point[@]})" > ./db/points.txt

}

