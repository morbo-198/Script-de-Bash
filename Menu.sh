#!/bin/bash

#Colores a usar en ANSI
COLOR_RESET="\033[0m"
COLOR_SELECTED_BG="\033[48;5;24m"
COLOR_MENU_BG="\033[48;5;235"
COLOR_MENU_FG="\033[38;5;15m"

#Opciones del menú
opciones=("Editar permisos(SQUID) Internet" "Configuración de SQUID" "Ejecutando Listas" "Creando Regla NAT con MASQUERADE" "Salir")     #array de las opciones del menu
#opciones[0]="Opción 1"
num_opciones=${#opciones[@]}    #obtiene el total de elementos del array
opcion_seleccionada=0

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

#Funcion de cargando
cargando(){    
    local mensaje="$1"
    local tiempo_espera="$2"
    local estilo="$3"
    clear
    #imprimir el mensaje con los puntos    
    echo -ne "$mensaje"
    
    case "$estilo" in
        1) #estilo puntos
            for ((i=0; i<7; i++)); do
                echo -n "."
                sleep $tiempo_espera
            done
        ;;
        2) #estilo porcentaje 
            for ((i=0; i<=100; i+=2)); do
                echo -ne "\r$mensaje: $i%"
                sleep $tiempo_espera
            done
        ;;    
    esac

    #limpiar la línea del mensaje
    echo -ne "\r"  
}

#Funcion para verificar si esta como root
verificaRoot(){    
    idUsuarios=$(id -u)

    if [ $idUsuarios -eq 0 ]; then
        return 0
    else
        return 1
    fi
}

#Funcion para comprobar la contraseña del root
checkPass(){
    echo -n "Ingrese la contraseña de sudo para [$(whoami)]: "
    read -s password    
    if echo "$password" | sudo -S true &>/dev/null; then
        return 0
    else
        return 1
    fi
}

#Funcion para ver si existe la masquerade
checkMasquerade(){
    if sudo iptables -t nat -C POSTROUTING -o eno1 -j MASQUERADE &>/dev/null; then
    sudo -v
        return 0
    else
        return 1
    fi
}

#Funcion para responder la pregunata
setSiNo(){
    local mensaje="$1";
    read -n 1 -p "$mensaje" respuesta 
    echo ""
    if [[ $respuesta == "S" || $respuesta == "s" ]]; then        
        return 0
    else        
        return 1
    fi
}

#Funcion texto parpadeante msj adventencias
warningMsj(){
    local texto="$1"
    local intervalo=1

    while true; do
        clear
        #echo -e "\e[43;5m$texto\nPresiona una tecla para continuar...\e[0m"
        echo -e "\e[30;43m$texto\nPresiona una tecla para continuar...\e[0m"
        sleep $intervalo
        clear
        echo -e "\e[97m$texto\nPresiona una tecla para continuar...\e[0m"        
        sleep $intervalo

        if read -t 0.1 -N 1; then
            break
        fi
    done
}

setSquidChanges(){
    warningMsj "Se ejecutara la revision de sintaxis, observe cuidadosamente el resultado en busca de errores o advertencias."
    clear
    echo "squid -k parse"
    read
    clear
    if setSiNo "¿Desea aplicar los cambios? (S/N): ";then
        warningMsj "Aplicando los cambios al finalizar verifique que no se muestren errores"
        clear
        echo "squid -k reconfigure"
        read
    else
        echo "No aplico los cambios"
        read
    fi
}

#Ciclo para mostrar y pintar el menu
while true; do
    sudo -k
    mostrar_menu
    IFS= read -rsn1 input    #guardando tecla presionada en variable input    

    case "$input" in
    #case que controla las teclas arriba y abajo
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
        $'\x20')   

#############Accion cuando presiona la opcion de salir
            if [ $opcion_seleccionada -eq $((num_opciones-1)) ]; then
                break
            fi            
            
############Accion cuando presiona la opcion de editar permisos          
            if [ $opcion_seleccionada -eq $((num_opciones-5)) ]; then
                              
                if verificaRoot; then                
                    cargando "Abriendo Lista Mortales" 0.03 2
                    clear                               
                    nano /home/memo/listas/listas.sh            
                    cargando "Abriendo Lista Olimpo" 0.03 2
                    clear
                    nano /home/memo/listas/listas2.sh
                    setSquidChanges
                    #warningMsj "Se ejecutara la revision de sintaxis, observe cuidadosamente el resultado en busca de errores o advertencias."                   
                    #clear
                    #echo "squid -k parse"
                    #read -n 1
                    #warningMsj "Al aplicar los cambios si el resultado anterior contaba con errores, esto podria ocasionar problemas"
                    #clear
                    #if setSiNo "¿Desea aplicar los cambios? (S/N): ";then
                    #    echo "squid -k reconfigure"
                    #    read
                    #else
                    #    echo "No aplico los cambios"
                    #    read
                    #fi
                    clear                    

                elif  ! verificaRoot; then
                    clear                    
                    if checkPass; then
                        cargando "Abriendo Lista Mortales" 0.03 2
                        clear 
                        nano /home/memo/listas/listas.sh            
                        cargando "Abriendo Lista Olimpo" 0.03 2
                        clear
                        nano /home/memo/listas/listas2.sh
                        setSquidChanges
                        #warningMsj "Se ejecutara la revision de sintaxis, observe cuidadosamente el resultado en busca de errores o advertencias."
                        #clear
                        #echo "squid -k parse"
                        #read -n 1
                        #warningMsj "Al aplicar los cambios si el resultado anterior contaba con errores, esto podria ocasionar problemas"
                        #clear
                        #if setSiNo "¿Desea aplicar los cambios? (S/N): ";then
                        #    echo "squid -k reconfigure"
                        #    read
                        #else
                        #    echo "No aplico los cambios"
                        #    read
                        #fi
                        clear
                    elif ! $?; then
                        cargando "Contraseña incorrecta." 0.2 1
                    fi
                    cargando "Regresando al Menu" 0.3 1
                    #stty echo
                fi
            fi
############Accion que realiza cuando selecciona Configuracion de SQUID
            if [ $opcion_seleccionada -eq $((num_opciones-4)) ]; then
                clear                             
                if verificaRoot; then
                    cargando "Abriendo archivo de configuracion SQUID" 0.03 2
                    clear
                    nano squid.conf
                elif ! verificaRoot; then
                    if checkPass; then
                        cargando "Abriendo archivo de configuracion SQUID" 0.03 2
                        clear
                        nano squid.conf                        
                    elif ! $?; then
                        cargando "Contraseña incorrecta." 0.2 1
                    fi
                    cargando "Regresando al Menu" 0.3 1
                fi
            fi

############Accion que realiza cuando selecciona Ejecutando Listas
            if [ $opcion_seleccionada -eq $((num_opciones-3)) ]; then   
                clear                                
                archivoLog="log.txt"
                touch "$archivoLog"
                fechaActual=$(date +'%d/%m/%Y')
                ultimaLinea=$(tail -n 1 log.txt)

                if [[ $ultimaLinea == *"Hora de ejecucion de las listas fue en: $fechaActual"* ]]; then
                    echo "Las listas ya fueron ejecutadas el dia de hoy a las $(echo "$ultimaLinea" | grep -oP 'Hora de ejecucion de las listas fue en: \d{2}/\d{2}/\d{4} \K\d{2}:\d{2}:\d{2}')."
                    if setSiNo "¿Desea ejecutarlo de nuevo? (S/N): "; then
                        warningMsj "Cuando termine la ejecución de las lista comprueba que no se muestren errores"
                        cargando "Las listas seran ejecutadas de nuevo" 0.1 1
                        echo "Hora de ejecucion de las listas fue en: $(date +'%d/%m/%Y %H:%M:%S')" >> log.txt                        
                    else
                        read -s -n 1 -p "Las listas no seran ejecutadas. Presione una tecla para continuar..."
                    fi                    
                else
                    warningMsj "Cuando termine la ejecución de las lista comprueba que no se muestren errores"
                    cargando "No se a ejecutado el dia de hoy. A continuacion seran ejecutadas" 0.2 1
                    echo "Hora de ejecucion de las listas fue en: $(date +'%d/%m/%Y %H:%M:%S')" >> log.txt                    
                fi                
                cargando "Regresando al Menu" 0.3 1             
            fi

#############Accion que realiza cuando selecciona Creando Regla NAT con MASQUERADE
            if [ $opcion_seleccionada -eq $((num_opciones-2)) ]; then   
                clear
                if verificaRoot; then
                    if checkMasquerade; then
                        clear
                        echo "La Regla ya existe:"
                        iptables -t nat -S | grep 'POSTROUTING -o eno1 -j MASQUERADE'                        
                        read -s -n 1 -p "Presione una tecla para continuar..."
                    elif ! checkMasquerade; then
                        clear
                        if setSiNo "La MASQUERADE no existe.¿Desea crearla? (S/N): "; then
                            iptables -t nat -A POSTROUTING -o eno1 -j MASQUERADE
                            cargando "Masquerade creada" 0.02 2
                        else
                            cargando "No se creara la masquerade" 0.2 1
                        fi
                    fi
                elif ! verificaRoot; then                         
                    if checkPass; then        
                        if checkMasquerade; then                        
                            clear
                            echo "La Regla ya existe:"                            
                            sudo iptables -t nat -S | grep 'POSTROUTING -o eno1 -j MASQUERADE'
                            read -s -n 1 -p "Presione una tecla para continuar..."
                        elif ! checkMasquerade; then                        
                            clear
                            if setSiNo "La MASQUERADE no existe.¿Desea crearla? (S/N): "; then
                                sudo iptables -t nat -A POSTROUTING -o eno1 -j MASQUERADE                                
                                cargando "Masquerade creada" 0.02 2
                            else                                
                                cargando "No se creara la masquerade" 0.2 1
                            fi                 
                        fi
                    else
                        cargando "Contraseña incorrecta." 0.2 1
                    fi
                fi  
                cargando "Regresando al Menu" 0.3 1
            fi
        ;;
    esac
done    
clear