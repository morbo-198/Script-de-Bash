#!/bin/bash

#Colores a usar en ANSI
COLOR_RESET="\033[0m"
COLOR_SELECTED_BG="\033[48;5;24m"
COLOR_MENU_BG="\033[48;5;235"
COLOR_MENU_FG="\033[38;5;15m"

#Opciones del menú
opciones=("[ ]Opción 1" "[ ]Opción 2" "[ ]Opción 3" "Salir")     #array de las opciones del menu
opciones[1]="[x] Opción 1"
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
    #Case que controla las teclas arriba y abajo
        $'\x1B')
            read -rsn1 -t 0.1 input
                if [ "$input" = "[" ]; then
                    read -rsn1 -t 0.1 input
                    case "$input" in
                        A)
                            ((opcion_seleccionada > 0)) && ((opcion_seleccionada--))                    
                        ;;
                        B)
                            ((opcion_seleccionada < num_opciones-1)) && ((opcion_seleccionada++))
                        ;;
                    esac    
                fi
       ;;
       #Case que controla la tecla espacio
        "")
            #If que reacciona cuando la opcion seleccionada es la ultima pero antes se presiono la tecla espacio
            if [ $opcion_seleccionada -eq $((num_opciones-1)) ]; then
                break
            fi
        ;;
    esac            
done    
clear