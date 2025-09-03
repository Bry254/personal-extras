#!/bin/bash

if [ -z "$1" ]; then
    echo "Por favor, proporciona un argumento."
    exit 1
fi

case $1 in
    get-ip)
        hostname -i
        ;;
    wifi-get)
        echo $(bash /home/brayan/.config/ironbar/menu.sh wifi) $(nmcli -t -f active,ssid dev wifi | rg '^sí' | cut -d: -f2)
        ;;
    wifi-s)
        wifi_status=$(nmcli radio wifi)
        if [ "$wifi_status" = "enabled" ]; then
            nmcli radio wifi off
        else
            nmcli radio wifi on
        fi
        ;;
    blue-get)
        if bluetoothctl show 2>/dev/null | grep -q "Powered: no"; then
            echo " DESACTIVADO"
        else
            echo " ACTIVADO   "
        fi
        ;;
    blue-set)
        rfkill toggle bluetooth
        ;;
    host-get)
        if pgrep lnxrouter > /dev/null; then
            echo " $(jq -r '.name' /home/brayan/apps/hostpot/data.json)"
        else
            echo "Apagado "
        fi
        ;;
    host-set)
        sudo /usr/bin/bash /home/brayan/apps/hostpot.sh
        ;;
    host-gui)
        /home/brayan/apps/hostpot/.venv/bin/python /home/brayan/apps/hostpot/gui.py
        ;;
    media-playing)
        if [ "$(playerctl status 2>/dev/null)" = "Playing" ]; then
            echo ""
        else
            echo ""
        fi
        ;;
    media-get)
        app=$(pactl list sink-inputs | grep -E "application.name" | head -n 1 | sed 's/"//g')
        media=$(pactl list sink-inputs | grep -E "media.name" | head -n 1 | sed 's/"//g')
        echo "${app##*=}:${media##*=}"
        ;;
    media-play)
        playerctl play-pause
        if pgrep mpg123 > /dev/null; then
            if [[ "$(ps -o state= -p $(pgrep mpg123))" == "T" ]]; then
                kill -CONT $(pgrep mpg123) 
            else
                kill -STOP $(pgrep mpg123)
            fi
        fi
        ;;
    media-next)
        playerctl next
        ;;
    media-past)
        playerctl previous
        ;;
    media-select)
        if pgrep mpg123 > /dev/null; then
            echo "exit" > "/home/brayan/.config/eww/stop.music"
            pkill -9 mpg123
        else
            nohup bash /home/brayan/.config/eww/music_mpg123.sh &
        fi
        ;;
    temp)
        temp=$(sensors | grep "Package id 0:" | awk '{print $4}' | tr -d '+°C')
        temp_int=$(printf "%.0f" "$temp")

        if ((temp_int >= 80)); then
            icon=""
        elif ((temp_int >= 60)); then
            icon=""
        elif ((temp_int >= 40)); then
            icon=""
        elif ((temp_int >= 20)); then
            icon=""
        else
            icon=""
        fi
        echo "$temp°C $icon"
        ;;
    sunset)
        if pgrep gammastep >/dev/null; then
            pkill gammastep
        else
            nohup gammastep -O 2500 &
        fi
        ;;
    ram)
        free | awk '/Mem:/ {printf("%.2f\n", $3/$2 * 100)}'
        ;;
    light)
        brightnessctl | grep -oP '\d+(?=%)'
        ;;
    bat)
        battery_percentage=$(cat /sys/class/power_supply/BAT*/capacity)
        charging_status=$(cat /sys/class/power_supply/BAT*/status)
        rounded_battery=$((battery_percentage / 10 * 10))
        GREEN="\e[32m"
        if [ "$charging_status" == "Charging" ] || [ "$charging_status" == "Full" ]; then
            icon=""  # Icono para batería cargándose
        else
            case $rounded_battery in
                0)   icon="" ;;  # Muy baja
                10)  icon="" ;;
                20)  icon="" ;;
                30)  icon="" ;;
                40)  icon="" ;;
                50)  icon="" ;;
                60)  icon="" ;;
                70)  icon="" ;;
                80)  icon="" ;;
                90)  icon="" ;; 
                100) icon="" ;;  # Carga completa cuando no está cargando
                *)   icon="" ;;  # Icono genérico si algo falla
            esac
        fi
        echo "$icon $battery_percentage%"
        if bluetoothctl show 2>/dev/null | grep -q "Powered: yes"; then
            per=$(bluetoothctl info | grep "Battery Percentage" | grep -oP '\(\K[0-9]+(?=\))')
            echo " $per%"
        fi

        ;;
    bat-num)
        cat /sys/class/power_supply/BAT*/capacity
        ;;
    alive-get)
        if pgrep swayidle > /dev/null; then
            echo "󰌶"
        else
            echo "󰌵"
        fi
        ;;
    
    alive-set)
        if pgrep swayidle > /dev/null; then
            pkill -9 swayidle
        else
            nohup swayidle timeout 1000 'wlr-randr --output eDP-1 --off' resume 'wlr-randr --output eDP-1 --on' before-sleep 'hyprlock--no-fade-in' &
        fi
        ;;
    record-get)
        if pgrep -f gpu-screen-recorder > /dev/null; then
            echo "󰐽"
        else
            echo "󰑋"
        fi
        ;;
    
    record-set)
        if pgrep -f gpu-screen-recorder > /dev/null; then
            pkill -f gpu-screen-recorder
        else
            cd /run/media/brayan/DiscoLinux/videos/record/
            gpu-screen-recorder -w screen -f 30 -a default_output -c mkv -o "video$(ls -1 . | wc -l).mkv" &
        fi
        ;;

    qr)
        wl-paste | qrencode -t ANSI256
        ;;
    *)
        echo "Opción desconocida: $1"
        echo "Opciones disponibles: encender, apagar, reiniciar"
        ;;
esac
