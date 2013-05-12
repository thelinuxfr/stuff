#!/bin/bash
#
# Ce script distribue sous la licence GNU FDL a ete developpe à l'origine par Eric BOUCHE
#
# Site officiel du script : http://2037.org/ || http://forum.2037.biz/viewtopic.php?t=3797
#
# Permission vous est donnee de distribuer, modifier ce script tant que cette note apparait clairement
#
# Version 1.0.2 - 19 decembre 2005
#
# Version 2.2.0 - 9 fevrier 2007 par Shadow AOK <postmaster AT shadowprojects DOT org>

#
# Declaration des constantes
dateheure=`date +%s`
# Executable rrdtool
exec_rrdtool="/usr/bin/rrdtool"
rep_db_rrdtool="/usr/local/rrdtool"

host="TheLinuxFr.Org"
# Repertoire ou sont crees les images
rep_images="/var/www/thelinux/core/htdocs/services"

#
# Verification environnement de fonctionnement

if [ ! -x $exec_rrdtool ]
 then
  echo "Erreur execution rrdtool :: \$exec_rrdtool=$exec_rrdtool"
  exit 1
fi

if [ ! -w $rep_db_rrdtool ] || [ ! -w $rep_images ]
 then
  echo "Erreur r/w \$rep_db_rrdtool=$rep_db_rrdtool ou \$rep_images=$rep_images"
  exit 1
fi

# Marqueur execution
if [ -e $rep_db_rrdtool/run.pid ]
 then
  exit 1
 else
  touch $rep_db_rrdtool/run.pid
fi


# Hauteur de l'image
hauteur_image='175'
# Largeur de l'image
largeur_image='600'


#
# Graphique charge systeme


charge_1min=`cat /proc/loadavg | awk '{print $1}' | awk -F "." '{print int($1$2)}'`
charge_5min=`cat /proc/loadavg | awk '{print $2}' | awk -F "." '{print int($1$2)}'`
charge_15min=`cat /proc/loadavg | awk '{print $3}' | awk -F "." '{print int($1$2)}'`

# Base de donnes rrdtool charge
db_rrd_charge=charge.rrd

if [ ! -e $rep_db_rrdtool/$db_rrd_charge ]
then
$exec_rrdtool create $rep_db_rrdtool/$db_rrd_charge \
DS:charge_1min:GAUGE:576:0:U \
DS:charge_5min:GAUGE:576:0:U \
DS:charge_15min:GAUGE:576:0:U \
RRA:AVERAGE:0.5:1:576 \
RRA:AVERAGE:0.5:12:168 \
RRA:AVERAGE:0.5:144:62 \
RRA:AVERAGE:0.5:288:366 \
RRA:MAX:0.5:1:576 \
RRA:MAX:0.5:12:168 \
RRA:MAX:0.5:144:62 \
RRA:MAX:0.5:288:366
fi

 
# Enregistrement des valeurs dans la base rrdtool
$exec_rrdtool update $rep_db_rrdtool/$db_rrd_charge $dateheure:$charge_1min:$charge_5min:$charge_15min



# Titre
TITRE="Charge système"

for i in -1day -1week -1month -1year
do
# Generation du graphique pour $i
$exec_rrdtool graph $rep_images/charge$i.gif \
-t "$TITRE sur $host" \
-v "Charge x 100" \
-w $largeur_image -h $hauteur_image \
--start $i \
DEF:charge_1min=$rep_db_rrdtool/$db_rrd_charge:charge_1min:AVERAGE \
DEF:charge_5min=$rep_db_rrdtool/$db_rrd_charge:charge_5min:AVERAGE \
DEF:charge_15min=$rep_db_rrdtool/$db_rrd_charge:charge_15min:AVERAGE \
LINE2:charge_1min\#FF0000:"Charge 1 minutes" \
LINE2:charge_5min\#00FF00:"Charge 5 minutes" \
LINE2:charge_15min\#0000FF:"Charge 15 minutes \n" \
GPRINT:charge_1min:MAX:"Charge Système  1 minute  \: MAX %6.2lf %s |" \
GPRINT:charge_1min:AVERAGE:"MOY %5.2lf %s |" \
GPRINT:charge_1min:LAST:"ACTU %6.2lf %s \n" \
GPRINT:charge_5min:MAX:"Charge Système  5 minutes \: MAX %6.2lf %s |" \
GPRINT:charge_5min:AVERAGE:"MOY %5.2lf %s |" \
GPRINT:charge_5min:LAST:"ACTU %6.2lf %s \n" \
GPRINT:charge_15min:MAX:"Charge Système 15 minutes \: MAX %6.2lf %s |" \
GPRINT:charge_15min:AVERAGE:"MOY %5.2lf %s |" \
GPRINT:charge_15min:LAST:"ACTU %6.2lf %s \n"
done



#
# Graphique cpu (Central Processing Unit)

for h in cpu0
do

# Base de donnees rrdtool cpu
db_rrd_cpu=cpu_$h.rrd
if [ ! -e $rep_db_rrdtool/$db_rrd_cpu ]
then
$exec_rrdtool create $rep_db_rrdtool/$db_rrd_cpu \
DS:utilisateur:COUNTER:576:0:U \
DS:nice:COUNTER:576:0:U \
DS:systeme:COUNTER:576:0:U \
RRA:AVERAGE:0.5:1:576 \
RRA:AVERAGE:0.5:12:168 \
RRA:AVERAGE:0.5:144:62 \
RRA:AVERAGE:0.5:288:366 \
RRA:MAX:0.5:1:576 \
RRA:MAX:0.5:12:168 \
RRA:MAX:0.5:144:62 \
RRA:MAX:0.5:288:366
fi

#
# Commande pour recuperer l'utilisation cpu
utilisateur=`cat /proc/stat | /usr/bin/awk '/'$h' /{print int(($2+$3)/100)}'`
nice=`cat /proc/stat | /usr/bin/awk '/'$h' /{print int(($3)/100)}'`
systeme=`cat /proc/stat | /usr/bin/awk '/'$h' /{print int(($4)/100)}'`

# Enregistrement des valeurs dans la base rrdtool
$exec_rrdtool update $rep_db_rrdtool/$db_rrd_cpu $dateheure:$utilisateur:$nice:$systeme

# Titre
TITRE="Utilisation du Processeur $h"

for i in -1day -1week -1month -1year
do
# Generation du graphique pour $i
$exec_rrdtool graph $rep_images/processeur_$h$i.gif \
-t "$TITRE sur $host" \
-v "Util CPU 1/100 Seconde" \
-w $largeur_image -h $hauteur_image \
--start $i \
DEF:utilisateur=$rep_db_rrdtool/$db_rrd_cpu:utilisateur:AVERAGE \
DEF:nice=$rep_db_rrdtool/$db_rrd_cpu:nice:AVERAGE \
DEF:systeme=$rep_db_rrdtool/$db_rrd_cpu:systeme:AVERAGE \
CDEF:vtotale=utilisateur,systeme,+ \
CDEF:vutilisateur=vtotale,1,GT,0,utilisateur,IF \
CDEF:vnice=vtotale,1,GT,0,nice,IF \
CDEF:vsysteme=vtotale,1,GT,0,systeme,IF \
CDEF:vtotalectrl=vtotale,1,GT,0,vtotale,IF \
LINE2:vutilisateur\#FF0000:"Utilisateur" \
LINE2:vnice\#0000FF:"Nice" \
LINE2:vsysteme\#00FF00:"Système" \
LINE2:vtotalectrl\#FFFF00:"Somme \n" \
GPRINT:vutilisateur:MAX:"Utilisation Utilisateur \: MAX %6.2lf %s  |" \
GPRINT:vutilisateur:AVERAGE:"MOY %6.2lf %s  |" \
GPRINT:vutilisateur:LAST:"ACTU %6.2lf %s \n" \
GPRINT:vnice:MAX:"Utilisation Priorités   \: MAX %6.2lf %s  |" \
GPRINT:vnice:AVERAGE:"MOY %6.2lf %s  |" \
GPRINT:vnice:LAST:"ACTU %6.2lf %s \n" \
GPRINT:vsysteme:MAX:"Utilisation Système     \: MAX %6.2lf %s  |" \
GPRINT:vsysteme:AVERAGE:"MOY %6.2lf %s  |" \
GPRINT:vsysteme:LAST:"ACTU %6.2lf %s \n" \
GPRINT:vtotalectrl:MAX:"Utilisation Totale      \: MAX %6.2lf %s  |" \
GPRINT:vtotalectrl:AVERAGE:"MOY %6.2lf %s  |" \
GPRINT:vtotalectrl:LAST:"ACTU %6.2lf %s \n"
done
done

#
# Graphique memoire vive et virtuelle

# Base de donnees rrdtool memoire vive et virtuelle
db_rrd_mem=memoire.rrd

if [ ! -e $rep_db_rrdtool/$db_rrd_mem ]
then
$exec_rrdtool create $rep_db_rrdtool/$db_rrd_mem \
DS:mem_ram_libre:GAUGE:576:0:U \
DS:mem_ram_util:GAUGE:576:0:U \
DS:mem_virtu_libre:GAUGE:576:0:U \
DS:mem_virtu_util:GAUGE:576:0:U \
RRA:AVERAGE:0.5:1:576 \
RRA:AVERAGE:0.5:12:168 \
RRA:AVERAGE:0.5:144:62 \
RRA:AVERAGE:0.5:288:366 \
RRA:MAX:0.5:1:576 \
RRA:MAX:0.5:12:168 \
RRA:MAX:0.5:144:62 \
RRA:MAX:0.5:288:366
fi

mem_ram_libre=$((`cat /proc/meminfo | /usr/bin/awk '/^MemFree: /{print $2}'` + `cat /proc/meminfo | /usr/bin/awk '/^Cached: /{print $2}'` + `cat /proc/meminfo | /usr/bin/awk '/^Buffers: /{print $2}'`))
mem_ram_util=$((`cat /proc/meminfo | /usr/bin/awk '/^MemTotal: /{print $2}'` - `cat /proc/meminfo | /usr/bin/awk '/^MemFree: /{print $2}'` - `cat /proc/meminfo | /usr/bin/awk '/^Cached: /{print $2}'` - `cat /proc/meminfo | /usr/bin/awk '/^Buffers: /{print $2}'`))
mem_virtu_libre=`cat /proc/meminfo | /usr/bin/awk '/^SwapFree: /{print $2}'`
mem_virtu_util=$((`cat /proc/meminfo | /usr/bin/awk '/^SwapTotal: /{print $2}'` - `cat /proc/meminfo | /usr/bin/awk '/^SwapFree: /{print $2}'`))

# Enregistrement des valeurs dans la base rrdtool
$exec_rrdtool update $rep_db_rrdtool/$db_rrd_mem $dateheure:$mem_ram_libre:$mem_ram_util:$mem_virtu_libre:$mem_virtu_util


# Titre
TITRE="Charge mémoire"

# Creation du graphe
for i in -1day -1week -1month -1year
do
$exec_rrdtool graph $rep_images/memoire$i.gif \
-t "$TITRE sur $host" \
-v "Mémoire en Octets" \
-w $largeur_image -h $hauteur_image \
--start $i \
DEF:mem_ram_libre=$rep_db_rrdtool/$db_rrd_mem:mem_ram_libre:AVERAGE \
DEF:mem_ram_util=$rep_db_rrdtool/$db_rrd_mem:mem_ram_util:AVERAGE \
DEF:mem_virtu_libre=$rep_db_rrdtool/$db_rrd_mem:mem_virtu_libre:AVERAGE \
DEF:mem_virtu_util=$rep_db_rrdtool/$db_rrd_mem:mem_virtu_util:AVERAGE \
CDEF:mem_virtu_libre_tt=mem_virtu_util,mem_virtu_libre,+,1024,* \
CDEF:mem_virtu_util_tt=mem_virtu_util,1024,* \
CDEF:mem_ram_tt=mem_ram_util,mem_ram_libre,+,1024,* \
CDEF:mem_ram_util_tt=mem_ram_util,1024,* \
LINE3:mem_ram_util_tt\#FFFF00:"Mémoire vive utilisée" \
LINE2:mem_virtu_util_tt\#FF0000:"Mémoire virtuelle utilisée\n" \
GPRINT:mem_ram_tt:LAST:"Mém  \: DISPO %.2lf %s  |" \
GPRINT:mem_ram_util_tt:MAX:"MAX %.2lf %s  |" \
GPRINT:mem_ram_util_tt:AVERAGE:"MOY %.2lf %s  |" \
GPRINT:mem_ram_util_tt:LAST:"ACTU %.2lf %s\n" \
GPRINT:mem_virtu_libre_tt:LAST:"Swap \: DISPO %.2lf %s  |" \
GPRINT:mem_virtu_util_tt:MAX:"MAX %.2lf %s  |" \
GPRINT:mem_virtu_util_tt:AVERAGE:"MOY %.2lf %s  |" \
GPRINT:mem_virtu_util_tt:LAST:"ACTU %.2lf %s"
done

#
# Graphique carte reseau

for h in eth0
do

# Base de donnes rrdtool $h
db_rrd_if=if_$h.rrd

if [ ! -e $rep_db_rrdtool/$db_rrd_if ]
then
$exec_rrdtool create $rep_db_rrdtool/$db_rrd_if \
DS:traf_in_if:COUNTER:576:0:U \
DS:traf_out_if:COUNTER:576:0:U \
RRA:AVERAGE:0.5:1:576 \
RRA:AVERAGE:0.5:12:168 \
RRA:AVERAGE:0.5:144:62 \
RRA:AVERAGE:0.5:288:366 \
RRA:MAX:0.5:1:576 \
RRA:MAX:0.5:12:168 \
RRA:MAX:0.5:144:62 \
RRA:MAX:0.5:288:366
fi

traf_in_if=`/sbin/ifconfig $h | grep "RX bytes" | cut -f2 -d: | cut -f1 -d " "`
traf_out_if=`/sbin/ifconfig $h | grep "RX bytes" | cut -f3 -d: | cut -f1 -d " "`

# Enregistrement des valeurs dans la base rrdtool
$exec_rrdtool update $rep_db_rrdtool/$db_rrd_if $dateheure:$traf_in_if:$traf_out_if

# Titre
TITRE="Trafic réseau $h"

for i in -1day -1week -1month -1year
do
# Generation du graphique pour $i
$exec_rrdtool graph $rep_images/if_$h$i.gif \
-t "Historique $TITRE sur $host" \
-v "Trafic en Octets / Seconde" \
-w $largeur_image -h $hauteur_image \
--start $i \
DEF:inb=$rep_db_rrdtool/$db_rrd_if:traf_in_if:AVERAGE \
DEF:outb=$rep_db_rrdtool/$db_rrd_if:traf_out_if:AVERAGE \
CDEF:ino=inb,8,* \
CDEF:outo=outb,8,* \
AREA:ino\#00FF00:"Trafic entrant" \
LINE2:outo\#0000FF:"Trafic sortant \n" \
GPRINT:ino:MAX:"Trafic entrant \: MAX %6.2lf %s  |" \
GPRINT:ino:AVERAGE:"MOY %6.2lf %s  |" \
GPRINT:ino:LAST:"ACTU %6.2lf %s \n" \
GPRINT:outo:MAX:"Trafic sortant \: MAX %6.2lf %s  |" \
GPRINT:outo:AVERAGE:"MOY %6.2lf %s  |" \
GPRINT:outo:LAST:"ACTU %6.2lf %s \n"
done
done

#
# Espace de stockage

for h in sda1 sda3
do

# Base de donnees rrdtool espace
db_rrd_space=space_$h.rrd

if [ ! -e $rep_db_rrdtool/$db_rrd_space ]
then
$exec_rrdtool create $rep_db_rrdtool/$db_rrd_space \
DS:esp_libre:GAUGE:576:0:U \
DS:esp_util:GAUGE:576:0:U \
RRA:AVERAGE:0.5:1:576 \
RRA:AVERAGE:0.5:12:168 \
RRA:AVERAGE:0.5:144:62 \
RRA:AVERAGE:0.5:288:366 \
RRA:MAX:0.5:1:576 \
RRA:MAX:0.5:12:168 \
RRA:MAX:0.5:144:62 \
RRA:MAX:0.5:288:366
fi


esp_libre=`/bin/df --block-size=1024 | /usr/bin/awk '/\/dev\/'$h' / {print $4}'`
esp_util=`/bin/df --block-size=1024 | /usr/bin/awk '/\/dev\/'$h' / {print $3}'`

# Enregistrement des valeurs dans la base rrdtool
$exec_rrdtool update $rep_db_rrdtool/$db_rrd_space $dateheure:$esp_libre:$esp_util

# Titre
TITRE="Espace $h"
for i in -1day -1week -1month -1year
do
# Generation du graphique pour $i
$exec_rrdtool graph $rep_images/space_$h$i.gif \
-t "$TITRE sur $host" \
-v "Espace en Octets" \
-w $largeur_image -h $hauteur_image \
--start $i \
DEF:esp_libre=$rep_db_rrdtool/$db_rrd_space:esp_libre:AVERAGE \
DEF:esp_util=$rep_db_rrdtool/$db_rrd_space:esp_util:AVERAGE \
CDEF:esp_libreo=esp_libre,1000,* \
CDEF:esp_utilo=esp_util,1000,* \
AREA:esp_utilo\#00FF00:"Espace utilisé" \
LINE2:esp_libreo\#0000FF:"Espace libre \n" \
GPRINT:esp_libreo:MAX:"Espace libre  \: MAX %6.2lf %s  |" \
GPRINT:esp_libreo:AVERAGE:"MOY %6.2lf %s  |" \
GPRINT:esp_libreo:LAST:"ACTU %6.2lf %s \n" \
GPRINT:esp_utilo:MAX:"Espace occupé \: MAX %6.2lf %s  |" \
GPRINT:esp_utilo:AVERAGE:"MOY %6.2lf %s  |" \
GPRINT:esp_utilo:LAST:"ACTU %6.2lf %s \n"
done
done


# Suppr marqueur Execution
rm $rep_db_rrdtool/run.pid

exit 0
