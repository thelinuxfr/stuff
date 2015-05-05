#!/bin/bash

#    debserver8.sh - a bunch of functions used in the other scripts
#
#    DEBServer8 - Debian Install Server Scripts
#    A set of scripts to automate installation of Servers on Debian
#    Copyright (c) 2015 Frédéric LIETART - stuff@thelinuxfr.org
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.
#

# simple input thing
# USAGE:
# getInpute "Enter the info we need please : " type default
# type = user | pw | domain | dir
# default = optional default response
# var1="${ANSWER}"
getInpute () {
	COUNTER=0
	if [ "${2}" = "user" ]; then REGEX="^([0-9a-z\-]{3,16})$"; fi
	if [ "${2}" = "pw" ]; then REGEX="^.{6,}$"; fi
	if [ "${2}" = "dir" ]; then REGEX="^[/a-zA-Z0-9_\.\-]+$"; fi
	if [ "${2}" = "domain" ]; then REGEX="^[a-z0-9\.\-]+$"; fi
	if [ "${2}" = "db" ]; then REGEX="^[a-zA-Z0-9_\.\-]+$"; fi
#	if [ "${2}" = "ip" ]; then REGEX="^[0-9{3}\.]{3}[0-9]{3}$"; fi
	if [ "${2}" = "ip" ]; then REGEX="^([1]?[0-9]?[0-9]|2[0-5][0-9]|25[0-4])\.([1]?[0-9]?[0-9]|2[0-4][0-9]|25[0-5])\.([1]?[0-9]?[0-9]|2[0-4][0-9]|25[0-5])\.([1]?[0-9]?[0-9]|2[0-4][0-9]|25[0-4])$"; fi
	if [ "${2}" = "yn" ]; then REGEX="^[ynYN]$"; fi
	echo -n "${1} "
	while read ANSWER; do
		: ${ANSWER:="$3"}
		if [[ "${ANSWER}" =~ ${REGEX} ]] && [ -n "${ANSWER}" ]; then
			break
		fi
		if [ "${COUNTER}" = "0" ]; then
			echo -e "Answer contains forbidden characters,\nyou must use:"
			if [ "${2}" = "user" ]; then
				echo -e "\n- lower case letters\n- numbers (0-9)\n- between 3 and 16 characters"
			elif [ "${2}" = "pw" ]; then
				echo -e "\n- at least 6 characters"
			elif [ "${2}" = "dir" ]; then
				echo -e "\n- lower/upper case letters\n- numbers\n- \". _ - /\""
			elif [ "${2}" = "domain" ]; then
				echo -e "\n- lower case letters\n- numbers\n- \". -\""
			elif [ "${2}" = "db" ]; then
				echo -e "\n- lower/upper case letters\n- numbers\n- \". _ -\""
			elif [ "${2}" = "ip" ]; then
				echo -e "\n- a valid IPv4"
			fi
			echo -n "
${1} "
			COUNTER="`expr $COUNTER + 1`"
		else
			echo " Bad answer please try again"
			echo -n "${1} "
		fi
	done
}

# Syntaxe: # su - -c "./debserver8.sh"
# Syntaxe: or # sudo ./debserver8.sh
VERSION="8.0.1"
clear

#=============================================================================
# Liste des applications à installer: A adapter a vos besoins
# Voir plus bas les applications necessitant un depot specifique
LISTE="ntp fail2ban htop rkhunter tree most ccze iftop safe-rm molly-guard manpages-fr manpages-fr-extra tmux bash-completion"
#=============================================================================

#=============================================================================
# Test que le script est lance en root
#=============================================================================
if [ $EUID -ne 0 ]; then
  echo "Le script doit être lancé en root: # sudo $0" 1>&2
  exit 1
fi
#=============================================================================

#=============================================================================
# Mise a jour de la liste des depots
#=============================================================================
echo "
deb http://httpredir.debian.org/debian jessie main contrib non-free
#deb-src http://httpredir.debian.org/debian jessie main contrib non-free

deb http://httpredir.debian.org/ jessie-updates main contrib non-free
#deb-src http://httpredir.debian.org/debian/ jessie-updates main contrib non-free

deb http://security.debian.org/ jessie/updates main contrib non-free
#deb-src http://security.debian.org/ jessie/updates main contrib non-free

###Third Parties Repos
## Deb-multimedia.org
#deb http://www.deb-multimedia.org jessie main non-free

## Debian Backports
#deb http://httpredir.debian.org/debian jessie-backports main

## HWRaid
# wget -O - http://hwraid.le-vert.net/debian/hwraid.le-vert.net.gpg.key | sudo apt-key add -
#deb http://hwraid.le-vert.net/debian jessie main" > /etc/apt/sources.list
#=============================================================================

#=============================================================================
# Update 
#=============================================================================
echo -e "\033[34m========================================================================================================\033[0m"
echo "Mise a jour de la liste des depots"
echo -e "\033[34m========================================================================================================\033[0m"
apt-get update
clear
#=============================================================================

#=============================================================================
# Upgrade
#=============================================================================
echo -e "\033[34m========================================================================================================\033[0m"
echo "Mise a jour du systeme"
echo -e "\033[34m========================================================================================================\033[0m"
apt-get upgrade
clear
#=============================================================================

#=============================================================================
# Installation
#=============================================================================
echo -e "\033[34m========================================================================================================\033[0m"
echo "Installation des logiciels suivants: $LISTE"
echo -e "\033[34m========================================================================================================\033[0m"
apt-get -y install $LISTE
#=============================================================================

#=============================================================================
# Configuration bashrc
#=============================================================================
cd /root &&
wget https://raw.githubusercontent.com/thelinuxfr/stuff/master/contribs/bashrc && mv bashrc .bashrc
clear
#=============================================================================

#=============================================================================
# Email admin
#=============================================================================
echo -n "Adresse mail pour les rapports de securite: "
read MAIL 
#=============================================================================

#=============================================================================
# Reconfigure openssh-server !
#=============================================================================
echo -n "Voulez-vous autoriser l'accès root via SSH (y/N): "
read SSHROOT
: ${SSHROOT:="N"}
if [[ ${SSHROOT} == [Yy] ]]; then
	echo 'openssh-server openssh-server/permit-root-login boolean true' | debconf-set-selections
	sed -i "s/PermitRootLogin without-password/PermitRootLogin yes/g" /etc/ssh/sshd_config
	systemctl restart ssh.service
fi
#=============================================================================

#=============================================================================
# Reconfigure locales !
#=============================================================================
echo -n "Voulez-vous reconfigurer locales (y/N): "
read LOCALES
: ${LOCALES:="N"}
if [[ ${LOCALES} == [Yy] ]]; then
	dpkg-reconfigure locales
fi
#=============================================================================

#=============================================================================
# Install beep
#=============================================================================
echo -n "Voulez-vous mettre en place un bip au démarrage/extinction de la machine (y/N): "
read BEEP
: ${BEEP:="N"}
if [[ ${BEEP} == [Yy] ]]; then
	wget https://raw.githubusercontent.com/thelinuxfr/stuff/master/contribs/beep && mv beep /etc/init.d/ && chmod +x /etc/init.d/beep && update-rc.d beep defaults
fi
#=============================================================================

#=============================================================================
# Désactiver les paquets recommandés !
#=============================================================================
echo -n "ATTENTION : Voulez-vous désactiver l'installation de paquets recommandés (y/N): "
read NORECOMMENDS
: ${NORECOMMENDS:="N"}
if [[ ${NORECOMMENDS} == [Yy] ]]; then
    echo "APT::Install-Recommends "0";
    APT::Install-Suggests "0"; " > /etc/apt/apt.conf
fi
#=============================================================================
clear

#=============================================================================
# Confirm IP addr
#=============================================================================
FOUNDIP=`ifconfig |grep Bcast|cut -d ":" -f 2|cut -d " " -f 1`
DEFAULTIP=`ifconfig |grep Bcast|cut -d ":" -f 2|cut -d " " -f 1|head -n 1`
echo -e "\033[34m========================================================================================================\\n IP(s) trouvée : ${FOUNDIP}\n========================================================================================================\\033[0m\n\nVérifier l'IP"
getInpute "Entrer IP [default ${DEFAULTIP}]:" ip ${DEFAULTIP}
IP="${ANSWER}"

# Change FQDN ?
FQDN=`hostname --fqdn`
echo -ne "\nThis machine should have a proper hostname setup, something like: 'server.domain.tld'.\n
Ideally it should correspond to the PTR of the IP ${IP}
(or at least the PTR of the the public IP).\n
The current fully qualified domain name appears to be: -> ${FQDN} <-\n\nDo you wan't to change that (y/N): "
read CHANGEFQDN
: ${CHANGEFQDN:="N"}
if [[ ${CHANGEFQDN} == [Yy] ]]; then
	getInpute "Entrer le nom de machine (pas le FQDN) (ex: server001):" domain
	MACHINENAME="${ANSWER}"
	getInpute "Entrer le nom de domaine (ex: domain.tld):" domain
	DOMAIN="${ANSWER}"
	FQDN="${MACHINENAME}.${DOMAIN}"
fi

# Change FQDN !
if [[ ${CHANGEFQDN} == [Yy] ]]; then
	echo ${FQDN} > /etc/hostname
	hostname ${MACHINENAME}
	echo "127.0.0.1       localhost
127.0.1.1	${FQDN} ${MACHINENAME}
${IP}	${FQDN} ${MACHINENAME}

::1     ip6-localhost ip6-loopback
fe00::0 ip6-localnet
ff00::0 ip6-mcastprefix
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters
ff02::3 ip6-allhosts"  > /etc/hosts
	echo -e "\n --> FQDN actuel de la machine : `hostname --fqdn`"
fi

echo "
# The primary network interface
#allow-hotplug eth0
#iface eth0 inet static
#	address 192.168.x.1
#	netmask 255.255.255.0
#	network 192.168.x.0
#	broadcast 192.168.x.255
#	gateway 192.168.x.254
#	dns-nameservers 192.168.x.1 x.x.x.x
#	dns-search domain.com

## Multi-IP ##
#auto eth0:0
#iface eth0:0 inet static
#    address 192.168.x.41
#    netmask 255.255.255.0
#    network 192.168.x.0
#    broadcast 192.168.x.255
#    gateway 192.168.x.254
#    dns-nameservers 192.168.x.1 x.x.x.x
#    dns-search domain.com
##

## Bonding ##
## apt-get install ifenslave-2.6
#iface bond0 inet static
#	address 192.168.x.1
#	netmask 255.255.255.0
#	network 192.168.x.0
#	broadcast 192.168.x.255
#	gateway 192.168.x.254
#	dns-nameservers 192.168.x.1 x.x.x.x
#	dns-search domain.com
#	bond-slaves eth0 eth1
#	bond-mode 1
#	bond-miimon 100
#	bond-primary eth0 eth1
##

## VLAN ##
# modprobe 8021q && apt-get install vlan
#iface vlanXX inet static
#        address 10.30.10.12
#        netmask 255.255.0.0
#        network 10.30.0.0
#        broadcast 10.30.255.255
#        vlan-raw-device eth0
##
" > /etc/network/interfaces.exemple
echo -e "\033[34m========================================================================================================\033[0m"
echo -e "Ajout d'exemple de configuration dans /etc/network/interfaces.exemple"
echo -e "\033[34m========================================================================================================\033[0m"
sleep 5
clear
#=============================================================================

#=============================================================================
# Install apt-listbugs
#=============================================================================
echo -n "Voulez-vous installer apt-listbugs (y/N): "
read APTLISTBUGS
: ${APTLISTBUGS:="N"}
if [[ ${APTLISTBUGS} == [Yy] ]]; then
	apt-get install apt-listbugs
fi
#=============================================================================

#=============================================================================
# Install smartmontools
echo -n "Voulez-vous installer smartmontools (y/N): "
read SMART
: ${SMART:="N"}
if [[ ${SMART} == [Yy] ]]; then
	apt-get install smartmontools
fi
#=============================================================================

#=============================================================================
# Install hdparm
#=============================================================================
echo -n "Voulez-vous installer hdparm (y/N): "
read HDPARM
: ${HDPARM:="N"}
if [[ ${HDPARM} == [Yy] ]]; then
	apt-get install hdparm
fi
#=============================================================================

#=============================================================================
# Install lm-sensors
#=============================================================================
echo -n "Voulez-vous installer lm-sensors (y/N): "
read LMSENSORS
: ${LMSENSORS:="N"}
if [[ ${LMSENSORS} == [Yy] ]]; then
	apt-get install lm-sensors
fi
#=============================================================================

#=============================================================================
# Configuration cron-apt
#=============================================================================
echo -n "Voulez-vous installer cron-apt (y/N): "
read CRONAPT
: ${CRONAPT:="N"}
if [[ ${CRONAPT} == [Yy] ]]; then
    apt-get -y install cron-apt
	echo "
APTCOMMAND=/usr/bin/apt-get
MAILTO="$MAIL"
MAILON="upgrade"" > /etc/cron-apt/config
echo -n "Voulez-vous installer les mises à jours automatiquements (Y/n): "
read CRONAPTAUTO
: ${CRONAPTAUTO:="Y"}
if [[ ${CRONAPTAUTO} == [Yy] ]]; then
    echo "dist-upgrade -y -o APT::Get::Show-Upgraded=true" > /etc/cron-apt/action.d/5-install
    echo 'DPkg::Post-Invoke { "if [ -x /usr/bin/rkhunter ] && grep -qiE '\''^APT_AUTOGEN=.?(true|yes)'\'' /etc/default/rkhunter; then /usr/share/rkhunter/scripts/rkhupd.sh; fi" }' > /etc/apt/apt.conf.d/90rkhunter
fi
fi
#=============================================================================

#=============================================================================
# Configuration Proxy APT
#=============================================================================
echo -n "Voulez-vous vous raccorder à un proxy APT (y/N): "
read PROXY
: ${PROXY:="N"}
if [[ ${PROXY} == [Yy] ]]; then
	echo -e "IP et port du proxy (example : 192.168.1.1:9999) ?"
	read IPPROXY
	echo "Acquire::http::Proxy "http://${IPPROXY}";" > /etc/apt/apt.conf.d/01proxy
fi
#=============================================================================

#=============================================================================
# Install Webmin
#=============================================================================
echo -n "Voulez-vous installer Webmin (y/N):"
read WEBMIN
: ${WEBMIN:="N"}
if [[ ${WEBMIN} == [Yy] ]]; then
	wget http://prdownloads.sourceforge.net/webadmin/webmin_1.740_all.deb &&
	dpkg --install webmin_1.740_all.deb ||
	apt-get install -fy &&
	rm webmin_1.740_all.deb
fi
#=============================================================================

#=============================================================================
# Install Avahi
#=============================================================================
echo -n "Voulez-vous installer Avahi Daemon (y/N): "
read AVAHI
: ${AVAHI:="N"}
if [[ ${AVAHI} == [Yy] ]]; then
	apt-get install avahi-daemon
	echo -e "\033[34m========================================================================================================\033[0m"
	echo -e "Veuillez vérifier le fichier /etc/nsswitch.conf"
	echo -e "hosts: files mdns4_minimal [NOTFOUND=return] dns mdns4 mdns"
	echo -e "\033[34m========================================================================================================\033[0m"
	sleep 5
fi
#=============================================================================

### Install Issue personnalisé
#echo -n "Voulez-vous une bannière de connexion personnalisée (y/N): "
#read ISSUE
#: ${ISSUE:="N"}
#if [[ ${ISSUE} == [Yy] ]]; then
#	wget http://dl.thelinuxfr.org/contribs/issue && mv issue /etc/issue
#fi
#=============================================================================

#=============================================================================
# END
#=============================================================================
echo -e "\033[34m========================================================================================================\033[0m"
echo "Liste d'applications utiles installées"
echo "$LISTE"
echo "Pensez à aller dans /etc/default pour configurer les daemons smartmontools hdparm"
echo -e "\033[34m========================================================================================================\033[0m"
#=============================================================================
