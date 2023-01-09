ゲームスタート
bash main.sh
※引数にautoを渡すと全自動化

揃ったペアを表示
watch -t -n 1 cat ./db/all_pair_history.txt

スコアを表示
watch -t -n 1 cat ./db/game_info.txt
