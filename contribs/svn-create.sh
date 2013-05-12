#!/bin/bash

if [ $# = 1 ]
	then
		echo -e "\033[1m#########################################################################################\033[0m"
		echo "Création Dépot SVN $1"
		echo -e "\033[1m#########################################################################################\033[0m"
	
		svnadmin create /var/svn/$1 &&

		mkdir -p /tmp/$1/{trunk,tags,branches} &&
		echo -e "Dev : svn checkout https://svn.thelinuxfr.org/svn/$1/ --username USER $1 \nUsers : svn checkout http://svn.thelinuxfr.org/svn/$1/ $1" > /tmp/$1/README &&
		svn import /tmp/$1 file:///var/svn/$1 -m "Initial Structure" &&
		rm -rdf /tmp/$1 &&

		chown -R apache:apache /var/svn/$1 
	else
		echo "Syntax : $0 DEPOT"
fi
