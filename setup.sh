#!/bin/bash

# Logo Artwork in ASCII
logoArt(){
	echo ""
	echo "  _____           _                                  _       ___    ___  "
	echo " |  __ \         | |                                | |     |__ \  / _ \ "
	echo " | |__) | __ ___ | |_ ___ ______ _ __ ___   ___  ___| |__      ) || | | |"
	echo " |  ___/ __/ _ \| __/ _  \______|  _  _   \/ _ \/ _ |_ _  \   / / | | | |"
	echo " | |   | | | (_) | || (_) |     | | | | | |  __/\__ \ | | |  / /_ | |_| |"
	echo " |_|   |_|  \___/ \__\___/      |_| |_| |_|\___||___/_| |_| |____(_)___/ "
	echo ""
}


FILE="/etc/proto-mesh/"
# Make sure proto-mesh is not already "installed"
if [ -d "$FILE" ] && [ "$1" != '-f' ]
then
   echo "Proto-Mesh 2.0 is already installed"
   echo "(Use -f if neccessary)"
   exit
fi

if [ "$(whoami)" != "root" ] ; then
   echo "Please run as root!"
   exit
fi

logoArt

cd cjdns
sudo bash setup.sh
