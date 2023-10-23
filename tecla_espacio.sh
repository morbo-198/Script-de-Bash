#!/bin/bash

while true; do
    IFS= read -rsn1 input
        if [[ "$input" == $'\x20' ]]; then
            echo "Se presionó la tecla de espacio"
            # Puedes realizar acciones específicas aquí si lo deseas
        fi
done