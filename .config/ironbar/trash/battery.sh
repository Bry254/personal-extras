#!/bin/bash

# Obtener la intensidad de la señal Wi-Fi
signal=$(iwconfig 2>/dev/null | grep -i --color signal | awk '{print $4}' | sed 's/level=//')

# Verificar si se obtuvo un valor válido
if [ -z "$signal" ]; then
    echo "󰤮"
    exit 0
fi

# Convertir la señal a un número absoluto
level=$((100 + signal))

# Asignar iconos según el nivel de la señal
if [ "$level" -ge 75 ]; then
    icon="󰤨"  # Señal fuerte
elif [ "$level" -ge 50 ]; then
    icon="󰤥"  # Señal buena
elif [ "$level" -ge 25 ]; then
    icon="󰤢"  # Señal débil
elif [ "$level" -ge 0 ]; then
    icon="󰤟"  # Señal muy débil
else
    icon="󰤯"  # No conectado
fi

# Mostrar el icono correspondiente
echo "$icon"
