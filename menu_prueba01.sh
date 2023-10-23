#!/bin/bash

#Colores a usar en ANSI
COLOR_RESET="\033[0m"
COLOR_SELECTED_BG="\033[48;5;24m"
COLOR_MENU_BG="\033[48;5;235"
COLOR_MENU_FG="\033[38;5;15m"

#Opciones del menú
opciones=("[  ]Opción 1" "[  ]Opción 2" "[  ]Opción 3" "Salir")     #array de las opciones del menu
num_opciones=${#opciones[@]}    #obtiene el total de elementos del array
opcion_seleccionada=1

#Función para mostrar el menú
mostrar_menu(){
    clear
    printf "\033[H"
    echo "Selecciona las opciones con las teclas Arriba (↑) y Abajo (↓)"
    for i in "${!opciones[@]}"; do
        if [ $i -eq $opcion_seleccionada ]; then
            echo -e "${COLOR_SELECTED_BG}${COLOR_MENU_FG} $((i+1)). ${opciones[i]} ${COLOR_RESET}"
        else
            echo -e "${COLOR_MENU_BG}${COLOR_MENU_FG} $((i+1)). ${opciones[i]} ${COLOR_RESET}"
        fi
    done
}

#Ciclo para mostrar y pintar el menu
while true; do    
    mostrar_menu
    read -rsn1 input    #guardando tecla presionada en variable input    
    case "$input" in
        $'\x1b\x5bA')
            ((opcion_seleccionada > 0)) && ((opcion_seleccionada--))
        ;;
        $'\x1b\x5bB')
            ((opcion_seleccionada < num_opciones-1)) && ((opcion_seleccionada++))
        ;;
    esac
done    
clear