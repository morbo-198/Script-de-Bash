#!/bin/bash
# Función para verificar el código de salida de los comandos
checkExitCode() {
    if [ $? -ne 0 ]; then
        echo "Error: No se pudo ejecutar el comando correctamente. Verifica la contraseña de sudo."        
    fi
}

# Comandos que deben ejecutarse con sudo
echo "Ejecutando comando con sudo:"
sudo iptables -t nat -S | grep 'POSTROUTING -o eno1 -j MASQUERADE'
checkExitCode

# Comandos que pueden ejecutarse sin sudo
echo "Ejecutando comandos sin sudo:"
read

