mi_variable=$(pamixer --get-mute)

if [ "$mi_variable" = "true" ]; then
    notify-send -a "changemute" "Muteado" -t 1000 -i "audio-volume-muted" -r 9993
else
    notify-send -a "changemute" "Desmuteado" -t 1000 -i "audio-volume-high" -r 9993
fi
