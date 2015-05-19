#!/bin/bash

#   debserver6.sh - a bunch of functions used in the other scripts
#
#   DEBServer6 - Debian Install Server Scripts
#   A set of scripts to automate installation of Servers on Debian
#   (c) 2012 Lietart Frederic - thelinuxfrATfree.fr
#
#   This file is part of DEBServer.
#
#   DEBServer6 free software: you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation, either version 3 of the License, or
#   (at your option) any later version.
#
#   DEBServer6 is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with DEBServer6.  If not, see <http://www.gnu.org/licenses/>.
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


# Syntaxe: # su - -c "./debserver6.sh"
# Syntaxe: or # sudo ./debserver6.sh
VERSION="6.0.6"
clear


#=============================================================================
# Liste des applications à installer: A adapter a vos besoins
# Voir plus bas les applications necessitant un depot specifique
# Securite
LISTE="ntp fail2ban htop rkhunter tree most ccze mc iftop smartmontools hdparm safe-rm molly-guard lm-sensors iotop apt-listbugs"
#=============================================================================

# Test que le script est lance en root
if [ $EUID -ne 0 ]; then
  echo "Le script doit être lancé en root: # sudo $0" 1>&2
  exit 1
fi


# Mise a jour de la liste des depots
#-----------------------------------
echo "
## squeeze
deb http://http.debian.net/debian/ squeeze main contrib non-free
#deb-src http://http.debian.net/debian/ squeeze main contrib non-free

## squeeze LTS
deb http://http.debian.net/debian squeeze-lts main contrib non-free
#deb-src http://http.debian.net/debian squeeze-lts main contrib non-free

## squeeze updates 
deb http://ftp.fr.debian.org/debian/ squeeze-updates main contrib non-free
# deb-src http://ftp.fr.debian.org/debian/ squeeze-updates main contrib non-free  

## Proposed-Updates
#deb http://ftp.fr.debian.org/debian squeeze-proposed-updates main contrib non-free

## squeeze-backports
#deb http://http.debian.net/debian-backports squeeze-backports-sloppy main

## squeeze multimedia
# deb http://www.debian-multimedia.org squeeze main non-free
# deb-src http://www.debian-multimedia.org squeeze main non-free" > /etc/apt/sources.list

# Update 
echo -e "\033[34m========================================================================================================\033[0m"
echo "Mise a jour de la liste des depots"
echo -e "\033[34m========================================================================================================\033[0m"
apt-get update

# Upgrade
echo -e "\033[34m========================================================================================================\033[0m"
echo "Mise a jour du systeme"
echo -e "\033[34m========================================================================================================\033[0m"
apt-get upgrade

clear
# Installation
echo -e "\033[34m========================================================================================================\033[0m"
echo "Installation des logiciels suivants: $LISTE"
echo -e "\033[34m========================================================================================================\033[0m"
apt-get -y install $LISTE

# Configuration bashrc
#--------------
wget https://gitlab.com/thelinuxfr/stuff/raw/master/debian/wheezy/bashrc && mv bashrc .bashrc

clear
### EMAIL ROOT ###
echo -e "\033[34m========================================================================================================\033[0m"
echo -e "Adresse mail pour les rapports de securite: "
echo -e "\033[34m========================================================================================================\033[0m"
read MAIL 

# Configuration
#--------------
### reconfigure locales !
echo -e "\033[34m========================================================================================================\033[0m"
echo -e "Voulez-vous reconfigurer locales (Y/n):"
echo -e "\033[34m========================================================================================================\033[0m"
read LOCALES
: ${LOCALES:="Y"}

if [[ ${LOCALES} == [Yy] ]]; then
	dpkg-reconfigure locales
fi
######

### Install byobu
echo -e "\033[34m========================================================================================================\033[0m"
echo -e "Voulez-vous installer byobu (Y/n):"
echo -e "\033[34m========================================================================================================\033[0m"
read BYOBU
: ${BYOBU:="Y"}

if [[ ${BYOBU} == [Yy] ]]; then
	apt-get install -f byobu
	wget https://gitlab.com/thelinuxfr/stuff/raw/master/contribs/byobu/color &&
	wget https://gitlab.com/thelinuxfr/stuff/raw/master/contribs/byobu/keybindings &&
	wget https://gitlab.com/thelinuxfr/stuff/raw/master/contribs/byobu/status &&
	mkdir $HOME/.byobu && mv color status keybindings $HOME/.byobu

fi
######

clear
### confirm IP addr
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
The current fully qualified domain name appears to be: -> ${FQDN} <-\n\nDo you wan't to change that (Y/n): "
read CHANGEFQDN
: ${CHANGEFQDN:="Y"}
if [[ ${CHANGEFQDN} == [Yy] ]]; then
	getInpute "Entrer le nom de machine (pas le FQDN) (ex: server001):" domain
	MACHINENAME="${ANSWER}"
	getInpute "Entrer le nom de domaine (ex: domain.tld):" domain
	DOMAIN="${ANSWER}"
	FQDN="${MACHINENAME}.${DOMAIN}"
fi

# Change FQDN !
if [[ ${CHANGEFQDN} == [Yy] ]]; then
	echo ${MACHINENAME} > /etc/hostname
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
### install unattended-upgrades
echo -e "\033[34m========================================================================================================\033[0m"
echo -e "Installation des mises à jours automatiques (Y/n):"
echo -e "\033[34m========================================================================================================\033[0m"
read UPDATE
: ${UPDATE:="Y"}
if [[ ${UPDATE} == [Yy] ]]; then
	apt-get install unattended-upgrades
	echo "
	APT::Periodic::Enable "1";
	APT::Periodic::Update-Package-Lists "1";
	APT::Periodic::Unattended-Upgrade "1";

	// APT::Periodic::Download-Upgradeable-Packages "1";
	// APT::Periodic::AutocleanInterval "5";
	// APT::Periodic::RandomSleep "1800";" > /etc/apt/apt.conf.d/10periodic

	echo "
	// Automatically upgrade packages from these (origin, archive) pairs
	// Unattended-Upgrade::Allowed-Origins {    
	//    "${distro_id} stable";
	//    "${distro_id} ${distro_codename}-security";
	//    "${distro_id} ${distro_codename}-updates";
	//  "${distro_id} ${distro_codename}-proposed-updates";
	// };

	// List of packages to not update
	// Unattended-Upgrade::Package-Blacklist {
	//  "vim";
	//  "libc6";
	//  "libc6-dev";
	//  "libc6-i686";
	// };

	// Send email to this address for problems or packages upgrades
	// If empty or unset then no email is sent, make sure that you 
	// have a working mail setup on your system. The package 'mailx'
	// must be installed or anything that provides /usr/bin/mail.
	Unattended-Upgrade::Mail "$MAIL";

	// Do automatic removal of new unused dependencies after the upgrade
	// (equivalent to apt-get autoremove)
	//Unattended-Upgrade::Remove-Unused-Dependencies "false";

	// Automatically reboot *WITHOUT CONFIRMATION* if a 
	// the file /var/run/reboot-required is found after the upgrade 
	//Unattended-Upgrade::Automatic-Reboot "false";" > /etc/apt/apt.conf.d/50unattended-upgrades

fi
######

### Configuration Proxy APT
echo -e "\033[34m========================================================================================================\033[0m"
echo -e "Voulez-vous vous raccorder à un proxy APT (Y/n):"
echo -e "\033[34m========================================================================================================\033[0m"
read PROXY
: ${PROXY:="Y"}

if [[ ${PROXY} == [Yy] ]]; then
	echo -e "IP et port du proxy (example : 192.168.1.1:9999) ?"
	read IPPROXY
	echo "Acquire::http::Proxy "http://${IPPROXY}";" > /etc/apt/apt.conf.d/01proxy
fi

### Install Webmin
echo -e "\033[34m========================================================================================================\033[0m"
echo -e "Voulez-vous installer Webmin (Y/n):"
echo -e "\033[34m========================================================================================================\033[0m"
read WEBMIN
: ${WEBMIN:="Y"}

if [[ ${WEBMIN} == [Yy] ]]; then
	wget http://prdownloads.sourceforge.net/webadmin/webmin_1.740_all.deb &&
	dpkg --install webmin_1.740_all.deb ||
	apt-get install -fy &&
	rm webmin_1.740_all.deb
fi

### Install VirtualBox
echo -e "\033[34m========================================================================================================\033[0m"
echo -e "Voulez-vous installer le dépôt Virtualbox (Y/n):"
echo -e "\033[34m========================================================================================================\033[0m"
read VBOX
: ${VBOX:="Y"}

if [[ ${VBOX} == [Yy] ]]; then
	echo "deb http://download.virtualbox.org/virtualbox/debian squeeze contrib non-free" >> /etc/apt/sources.list
	wget -q http://download.virtualbox.org/virtualbox/debian/oracle_vbox.asc -O- | apt-key add - &&
	apt-get update &&
	echo -e "\033[34m========================================================================================================\033[0m"
	echo -e "Vous pouvez maintenant installer VirtualBox via : apt-get install virtualbox-4.1"
	echo -e "\033[34m========================================================================================================\033[0m"
	sleep 5
fi

### Install DHCP Server
echo -e "\033[34m========================================================================================================\033[0m"
echo -e "Voulez-vous installer un serveur DNSMasq (DHCP/DNS) (Y/n):"
echo -e "\033[34m========================================================================================================\033[0m"
read DHCP
: ${DHCP:="Y"}

if [[ ${DHCP} == [Yy] ]]; then
	apt-get install dnsmasq
	echo -e "\033[34m========================================================================================================\033[0m"
	echo -e "Vous pouvez maintenant personnaliser la configuration : /etc/dnsmasq.conf"
	echo -e "http://wiki.debian.org/HowTo/dnsmasq | https://help.ubuntu.com/community/Dnsmasq | http://www.jopa.fr/index.php/2008/10/30/dnsmasq-dns-cache-et-dhcp/"
	echo -e "\033[34m========================================================================================================\033[0m"
	sleep 5
fi

### Install Avahi
echo -e "\033[34m========================================================================================================\033[0m"
echo -e "Voulez-vous installer Avahi Daemon (Y/n):"
echo -e "\033[34m========================================================================================================\033[0m"
read AVAHI
: ${AVAHI:="Y"}

if [[ ${AVAHI} == [Yy] ]]; then
	apt-get install avahi-daemon
	echo -e "\033[34m========================================================================================================\033[0m"
	echo -e "Veuillez modifier le fichier /etc/nsswitch.conf"
	echo -e "hosts: files mdns4_minimal [NOTFOUND=return] dns mdns4 mdns"
	echo -e "\033[34m========================================================================================================\033[0m"
	sleep 5
fi

### Install Issue personnalisé
echo -e "\033[34m========================================================================================================\033[0m"
echo -e "Voulez-vous une bannière de connexion personnalisée (Y/n):"
echo -e "\033[34m========================================================================================================\033[0m"
read ISSUE
: ${ISSUE:="Y"}

if [[ ${ISSUE} == [Yy] ]]; then
	wget https://gitlab.com/thelinuxfr/stuff/raw/master/contribs/issue && mv issue /etc/issue

fi

echo -e "\033[34m========================================================================================================\033[0m"
echo "Liste d'applications utiles installées"
echo "$LISTE"
echo "Pensez à aller dans /etc/default pour configurer les daemons smartmontools hdparm"
echo -e "\033[34m========================================================================================================\033[0m"
# Fin du script
