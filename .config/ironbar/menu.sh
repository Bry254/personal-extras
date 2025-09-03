#!/bin/bash

if [ -z "$1" ]; then
    echo "Por favor, proporciona un argumento."
    exit 1
fi

case $1 in
    baterry)
        echo $(lua /home/brayan/.config/ironbar/bateria.lua) $(bash /home/brayan/.config/eww/script_panel.sh bat) $(nmcli -t -f active,ssid dev wifi | grep '^sí' | cut -d: -f2)
        ;;
    wifi)
        signal=$(iwconfig 2>/dev/null | grep -i --color signal | awk '{print $4}' | sed 's/level=//')
        if [ -z "$signal" ]; then
            echo "󰤮"
            exit 0
        fi
        level=$((90 + signal))
        if [ "$level" -ge 40 ]; then
            icon="󰤨"  # Señal fuerte
        elif [ "$level" -ge 30 ]; then
            icon="󰤥"  # Señal buena
        elif [ "$level" -ge 20 ]; then
            icon="󰤢"  # Señal débil
        elif [ "$level" -ge 10 ]; then
            icon="󰤟"  # Señal muy débil
        else
            icon="󰤯"  # No conectado
        fi
        echo "$icon"
        # 0 10 20 30 40 | 45
        ;;
    ram)
        free | awk '/Mem:/ {printf("%.2f%\n", $3/$2 * 100)}'
        ;;
    volume)
        volume=$(pamixer --get-volume)
        notify-send -a "changevolume" -u low -r 9993 -h int:value:"$volume" -i "/usr/share/icons/Papirus-Dark/16x16/actions/speaker.svg" "Volumen: ${volume}%" -t 2000 
        ;;
    hour)
        date "+%I:%M%P %A"
        date "+%d /%B /%Y"
        ;;
    estado)
        battery_percentage=$(cat /sys/class/power_supply/BAT*/capacity)
        charging_status=$(cat /sys/class/power_supply/BAT*/status)
        rounded_battery=$((battery_percentage / 10 * 10))
        if [ "$charging_status" == "Charging" ] || [ "$charging_status" == "Full" ]; then
            icon=""  # Icono para batería cargándose
        else
            case $rounded_battery in
                0)   icon="" ;; 
                10)  icon="" ;;
                20)  icon="" ;;
                30)  icon="" ;;
                40)  icon="" ;;
                50)  icon="" ;;
                60)  icon="" ;;
                70)  icon="" ;;
                80)  icon="" ;;
                90)  icon="" ;; 
                100) icon="" ;;
                *)   icon="" ;;
            esac
        fi
        if bluetoothctl show 2>/dev/null | grep -q "Powered: yes"; then
            bluetooth_status=""
        else
            bluetooth_status=""
        fi
        echo "  $(free | awk '/Mem:/ {printf("%.2f%\n", $3/$2 * 100)}') $(lua /home/brayan/.config/ironbar/bateria.lua) $icon $battery_percentage% $bluetooth_status "
        ;;
    *)
        echo "Opción desconocida: $1"
        echo "Opciones disponibles: encender, apagar, reiniciar"
        ;;
esac