#!/bin/bash
if [ $# -ne 2 ];
then
echo "Usage: $0 <device> <parameter>"
exit
fi
 
/opt/local/sbin/smartctl -A $1 | grep $2 | tr -s ' ' | sed "s/^[[:space:]]*\(.*\)[[:space:]]*$/\1/" | cut -d " " -f 10
