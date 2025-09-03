#!/bin/bash

export DISPLAY=:0
export WAYLAND_DISPLAY=wayland-1
export DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$(id -u)/bus"

bateria="/sys/class/power_supply/BAT1/capacity"
estado="/sys/class/power_supply/BAT1/status"

porcentaje=$(cat "$bateria")
cargando=$(cat "$estado")

if [[ "$cargando" == "Discharging" ]]; then
   	if [[ "$porcentaje" -le 15 ]]; then
	    notify-send -a "Sistema" -u critical "Batería baja" "Conecta el cargador" -i "/usr/share/icons/Tela-blue-dark/16/panel/battery-000.svg" 
    fi
fi
