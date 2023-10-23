#!/bin/bash

while true; do
    IFS= read -rsn1 input

    case "$input" in
        $'\x1B')
            read -rsn1 -t 0.1 input
            if [ "$input" = "[" ]; then
                read -rsn1 -t 0.1 input
                case "$input" in
                    A)
                        echo "Tecla Arriba: ${input}"
                    ;;
                    B)
                        echo "Tecla Abajo: ${input}"
                    ;;
                    
                esac
            fi
        ;;
        $'\x20')
            echo "Tecla Espacio: ${input}"
        ;;
    esac
done