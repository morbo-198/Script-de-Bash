#!/bin/bash

parpadear() {
    local texto="$1"
    local intervalo=0.8

    while true; do
        clear
        echo -e "\e[43;5m$texto\nPresiona una tecla para continuar...\e[0m"        
        sleep $intervalo
        clear
        echo -e "\e[97m$texto\nPresiona una tecla para continuar...\e[0m"        
        sleep $intervalo

        # Verificar si se ha presionado una tecla
        if read -t 0.01 -n 1; then
            break
        fi
    done
}

# Cambia "Texto Parpadeante" con tu propio texto
parpadear "Texto Parpadeante"