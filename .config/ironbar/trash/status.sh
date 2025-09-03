#!/bin/bash

# Obtiene el porcentaje de batería
battery_percentage=$(cat /sys/class/power_supply/BAT*/capacity)

# Verifica el estado de la batería (cargando o no)
charging_status=$(cat /sys/class/power_supply/BAT*/status)

# Redondea a las decenas
rounded_battery=$((battery_percentage / 10 * 10))

GREEN="\e[32m"
# Define el ícono según el estado y rango de batería
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


#!/bin/bash

# Comprobar el estado del servicio de Bluetooth
if bluetoothctl show 2>/dev/null | grep -q "Powered: yes"; then
    bluetooth_status=""
else
    bluetooth_status=""
fi

echo "  $(free | awk '/Mem:/ {printf("%.2f%\n", $3/$2 * 100)}') $icon $battery_percentage% $bluetooth_status "
