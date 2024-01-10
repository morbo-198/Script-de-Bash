#!/bin/bash

#Colores a usar en ANSI
COLOR_RESET="\033[0m"
COLOR_SELECTED_BG="\033[48;5;24m"
COLOR_MENU_BG="\033[48;5;235"
COLOR_MENU_FG="\033[38;5;15m"

#Opciones del menú
opciones=("Editar permisos Internet" "Configuración de SQUID" "Ejecutando Listas" "Creando Regla NAT con MASQUERADE" "Salir")     #array de las opciones del menu
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
    mensaje="$1"
    tiempo_espera="$2"
    estilo="$3"
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
    usuarioActuals=$(whoami)    
    idUsuarios=$(id -u)

    if [ $idUsuarios -eq 0 ]; then
        return 0
    else
        return 1
    fi
}

#Funcion para comprobar la contraseña del root
checkPass(){
    echo -n "Ingrese la contraseña de sudo para$usuarioActual: "
    read -s password
    export SUDO_ASKPASS="askpass.sh"
    if echo "$password" | sudo -Sk true &>/dev/null; then
        export SUDO_ASKPASS="askpass.sh"
        return 0
    else
        return 1
    fi
}

checkExitCode() {
    if [ $? -ne 0 ]; then
        echo "Error: No se pudo ejecutar el comando correctamente. Verifica la contraseña de sudo."        
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

#Ciclo para mostrar y pintar el menu
while true; do    
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
                elif  ! verificaRoot; then
                    clear                                   
                    cargando "Abriendo Lista Mortales" 0.03 2
                    clear 
                    sudo -k nano /home/memo/listas/listas.sh
                    checkExitCode         
                    cargando "Abriendo Lista Olimpo" 0.03 2
                    clear
                    sudo -k nano /home/memo/listas/listas2.sh
                    checkExitCode                             
                    cargando "Regresando al Menu" 0.3 1
                    #stty echo
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
                    
                    read -n 1 -p "Las listas ya fueron ejecutadas el dia de hoy a las $(echo "$ultimaLinea" | grep -oP 'Hora de ejecucion de las listas fue en: \d{2}/\d{2}/\d{4} \K\d{2}:\d{2}:\d{2}').¿Desea ejecutarlo de nuevo? (S/N): " respuesta 
                    echo ""
                    if [[ $respuesta == "S" || $respuesta == "s" ]]; then
                        cargando "Las listas seran ejecutadas de nuevo" 0.1 1
                        echo "Hora de ejecucion de las listas fue en: $(date +'%d/%m/%Y %H:%M:%S')" >> log.txt
                    else
                        read -s -n 1 -p "Las listas no seran ejecutadas. Presione una tecla para continuar..."
                    fi

                else
                    cargando "No se a ejecutado el dia de hoy. A continuacion seran ejecutadas" 0.2 1
                    echo "Hora de ejecucion de las listas fue en: $(date +'%d/%m/%Y %H:%M:%S')" >> log.txt
                fi                
                cargando "Regresando al Menu" 0.3 1             
            fi

#############Accion que realiza cuando selecciona Creando Regla NAT con MASQUERADE
            if [ $opcion_seleccionada -eq $((num_opciones-2)) ]; then   
                clear
                if verificaRoot; then
                    echo "Con permisos"
                    read
                    if checkMasquerade; then
                        clear
                        echo "La Regla ya existe:"
                        iptables -t nat -S | grep 'POSTROUTING -o eno1 -j MASQUERADE'
                        read -s -n 1 -p "Presione una tecla para continuar..."
                    elif ! checkMasquerade; then
                        clear
                        read -n 1 -p "La MASQUERADE no existe.¿Desea crearla? (S/N): " respuesta 
                        echo ""
                        if [[ $respuesta == "S" || $respuesta == "s" ]]; then
                            iptables -t nat -A POSTROUTING -o eno1 -j MASQUERADE
                            cargando "Masquerade creada" 0.02 2
                        else
                            cargando "No se creara la masquerade" 0.2 1
                        fi
                    fi
                elif ! verificaRoot; then     
                    echo "SIN PERMISOS"
                    read                  
                        if checkMasquerade; then
                            clear
                            echo "La Regla ya existe:"                            
                            sudo iptables -t nat -S | grep 'POSTROUTING -o eno1 -j MASQUERADE'
                            sudo -k
                            read -s -n 1 -p "Presione una tecla para continuar..."
                        elif ! checkMasquerade; then                        
                            clear
                            read -n 1 -p "La MASQUERADE no existe.¿Desea crearla? (S/N): " respuesta 
                            echo ""                            
                            if [[ $respuesta == "S" || $respuesta == "s" ]]; then                                
                                SUDO_ASKPASS="askpass.sh" sudo iptables -t nat -A POSTROUTING -o eno1 -j MASQUERADE                                
                                cargando "Masquerade creada" 0.02 2
                            else
                                cargando "No se creara la masquerade" 0.2 1    
                            fi                    
                        fi
                fi  
                cargando "Regresando al Menu" 0.3 1
            fi
        ;;
    esac
done    
clear