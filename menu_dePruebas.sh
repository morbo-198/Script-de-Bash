#!/bin/bash

# Establece el intérprete de Bash para el script.

function print_menu()  # selected_item, ...menu_items
{
	local function_arguments=($@)

	# Declara una función llamada 'print_menu' con argumentos.

	local selected_item="$1"
	local menu_items=(${function_arguments[@]:1})
	local menu_size="${#menu_items[@]}"

	# Obtiene el 'selected_item' (opción seleccionada) y los 'menu_items' (elementos del menú) pasados como argumentos.
	# Calcula el tamaño del menú.

	for (( i = 0; i < $menu_size; ++i ))
	do
		if [ "$i" = "$selected_item" ]
		then
			echo "-> ${menu_items[i]}"
		else
			echo "   ${menu_items[i]}"
		fi
	done

	# Recorre los elementos del menú y los imprime, marcando la opción seleccionada con una flecha "->".
}

function run_menu()  # selected_item, ...menu_items
{
	local function_arguments=($@) #crea un array con  los todos los valores que se le pasaron como argumentos

	# Declara una función llamada 'run_menu' con argumentos.

	local selected_item="$1"
	local menu_items=(${function_arguments[@]:1}) #crea un array con los valores de los parametros excluyendo el 1 que no es parte del menu si no el elemento seleccionado
	local menu_size="${#menu_items[@]}"
	local menu_limit=$((menu_size - 1))

	# Obtiene el 'selected_item' y los 'menu_items' pasados como argumentos.
	# Calcula el tamaño del menú y el índice máximo.

	clear
	print_menu "$selected_item" "${menu_items[@]}" #Se manda a llamar a la funcion y se le pasan dos parametros
	
	# Limpia la pantalla y muestra el menú.

	while read -rsn1 input
	do
		case "$input"
		in
			$'\x1B')  # ESC ASCII code (https://dirask.com/posts/ASCII-Table-pJ3Y0j)

			# Cuando se presiona la tecla ESC (Escape):

				read -rsn1 -t 0.1 input
				if [ "$input" = "[" ]  # Ocurre antes del código de flecha
				then
					read -rsn1 -t 0.1 input
					case "$input"
					in
						A)  # Flecha hacia arriba

						# Cuando se presiona la flecha hacia arriba:
						
							if [ "$selected_item" -ge 1 ]
							then
								selected_item=$((selected_item - 1))
								clear
								print_menu "$selected_item" "${menu_items[@]}"
							fi
							;;

						B)  # Flecha hacia abajo

						# Cuando se presiona la flecha hacia abajo:

							if [ "$selected_item" -lt "$menu_limit" ]
							then
								selected_item=$((selected_item + 1))
								clear
								print_menu "$selected_item" "${menu_items[@]}"
							fi
							;;

					esac
				fi

				read -rsn5 -t 0.1  # Limpia la entrada estándar.
				;;

			"")  # Tecla Enter

			# Cuando se presiona la tecla Enter, retorna la opción seleccionada.

				return "$selected_item"
				;;

		esac
	done
}

# Uso del script:

selected_item=0
menu_items=('Login' 'Register' 'Guest' 'Exit')

# Establece la opción seleccionada y define los elementos del menú.

run_menu "$selected_item" "${menu_items[@]}"
menu_result="$?"

# Ejecuta el menú interactivo y obtiene el resultado.

echo

# Muestra una línea en blanco.

case "$menu_result"
in
	0)
		echo 'Login item selected'
		;;
	1)
		echo 'Register item selected'
		;;
	2)
		echo 'Guest item selected'
		;;
	3)
		echo 'Exit item selected'
		;;
esac
