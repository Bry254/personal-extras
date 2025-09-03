volume=$(pamixer --get-volume)
notify-send -a "Volumen" -u low -r 9993 -h int:value:"$volume" -i "/usr/share/icons/Tela-blue-dark/16/actions/speaker.svg" "${volume}%" -t 2000 