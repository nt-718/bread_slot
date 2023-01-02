#!/bin/bash

shopt -s extglob lastpipe
source ./array.txt

count() {
	count_num=`cat .all_pair_history.txt | grep "$1" | wc -l`
	echo "$count_num"
}

total_count() {

	total_count_num=`cat .all_pair_history.txt | wc -l`
	echo "total: $(($total_count_num - 2 ))"

}

prev=("")
paires=("")

cat ./all_pair_history.txt | while read line
do
	prev+=("$line")
done

for j in `seq 0 ${#prev[@]}`
do
	pair=`echo "${prev[$j]}" | cut -f 2 -d ":"`
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
		echo "$num ${paires[$k]}"
	done
}

now_rank=$(rank)

echo "$now_rank" | sort -n -r

total_count

#echo "$add"

now_count=$(($total_count_num - 2 ))

if [[ "$(( $now_count % 10 ))" == 0 ]] && [[ $now_count != 0 ]]; then
	add=`echo "$now_rank" | sort -n | head -n 1 | awk '{print $2}'`

	if [[ $flag == true ]]; then
		echo "original_array=(${original_array[@]})" > ./array.txt
		array_to_add=(${original_array[@]} ${original_array[@]})
		array_to_add+=("$add")
		echo "array=(${array_to_add[@]})" >> ./array.txt
		echo "flag=false" >> ./array.txt
		echo "fever=$add" >> ./array.txt

	fi
	
fi	

if [[ "$(( $now_count % 10 ))" != 0 ]] && [[ $flag == false ]]; then

	echo "original_array=(${original_array[@]})" > ./array.txt
	echo "array=(${array[@]})" >> ./array.txt
	echo "flag=true" >> ./array.txt
	echo "fever=$fever" >> ./array.txt
fi

if [[ $now_count -gt 10 ]]; then

	echo
	echo "🎉FEVER TIME🎉"
	echo "🤤 $fever 🤤"

	#echo "${array[@]}"
fi
