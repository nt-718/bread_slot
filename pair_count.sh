#!/bin/bash

shopt -s extglob lastpipe
source ./array.txt

prev=("")
paires=("")

cat ./all_pair_history.txt | while read line
do
	prev+=("$line")
done

for j in `seq 0 ${#prev[@]}`
do
	pair=`echo "${prev[$j]}" | cut -f 3 -d ":"`
	if printf '%s\n' "${paires[@]}" | grep -qx "$pair"; then
		:
	else
		paires+=("$pair")
	fi
done

rank(){
	for k in `seq 2 $((${#paires[@]} - 1 ))`
	do
		num=`count ${paires[$k]}`
		echo "${paires[$k]}"
	done
}


add_food() {

	add=`echo "${array[$(($RANDOM % ${#array[*]}))]}"`


	if [[ $flag == true ]]; then
		echo "original_array=(${original_array[@]})" > ./array.txt
		array_to_add=(${original_array[@]} ${original_array[@]} ${original_array[@]} 🐵)
		array_to_add+=("$add")
		echo "array=(${array_to_add[@]})" >> ./array.txt
		echo "flag=false" >> ./array.txt
		echo "fever=$add" >> ./array.txt
		echo
		echo "🎉$addが出やすくなりました🎉"

	fi
		
	if [[ $flag == false ]]; then
		echo "original_array=(${original_array[@]})" > ./array.txt
		echo "array=(${array[@]})" >> ./array.txt
		echo "flag=true" >> ./array.txt
		echo "fever=$fever" >> ./array.txt
	fi
}
