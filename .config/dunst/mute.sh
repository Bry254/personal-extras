mi_variable=$(pamixer --get-mute)

if [ "$mi_variable" = "true" ]; then
    notify-send -a "Mute" "Muteado" -t 1000 -i "/usr/share/icons/Tela-blue-dark/16/panel/audio-off.svg" -r 9993
else
    notify-send -a "Mute" "Desmuteado" -t 1000 -i "/usr/share/icons/Tela-blue-dark/16/panel/audio-on.svg" -r 9993
fi
