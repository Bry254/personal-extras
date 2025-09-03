light=$(brightnessctl | grep -oP '\d+(?=%)')
notify-send -a "Brillo" -u low -r 9993 -h int:value:"$light" -i "/usr/share/icons/Tela-blue-dark/22/panel/brightness-high.svg" "${light}%" -t 2000