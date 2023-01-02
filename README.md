# bread_slot

Windows Terminal画面分割
→縦横比の大きい方が分割される
shift+alt+矢印で調整する
wt.exe -w 0 split-pane -p "ubuntu" ubuntu.exe

履歴を表示
watch -t -n 1 cat all_
pair_history.txt

戦績を表示
tail -f slot_history.txt

ゲーム情報を表示
watch -t -d -n 1 bash bread_slot_view.sh
