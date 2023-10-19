#!/bin/bash

 read -rsn1 input

case "$input" in
    $'\x1B')
        read -rsn1 -t 0.1 input
        if [ "$input" = "[" ]; then
            read -rsn1 -t 0.1 input
            case "$input" in
                A)
                    echo "Tecla Arriba"
                ;;
                B)
                    echo "Tecla Abajo"
                ;;
                
            esac
        fi
    ;;
    "")
        echo "Tecla Espacio"
esac