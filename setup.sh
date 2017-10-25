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

#Enable and Start Service
echo "Starting protomesh service..."

#Generate Service File
sudo cp /etc/proto-mesh/utils/protomesh.service /etc/systemd/system/protomesh.service
sudo systemctl daemon-reload

#Prompt for Boot
read -p "Start Proto-Mesh on Boot (Y/n)? " CONT
CONT=${CONT,,} # tolower
if [ "$CONT" = "n" ]; then
  sudo systemctl disable protomesh.service
else
  sudo systemctl enable protomesh.service
fi


#Prompt to Confirm
read -p "Which System is being installed: [1] CJDNS [2] OpenFlow (1/2): " CONT
if [ "$CONT" = "1" ]; then
  cd cjdns
  sudo bash setup.sh
elif [ "$CONT" = "2" ]; then
  cd openflow
  sudo bash setup.sh
else
  #Report nothing has happened
  echo "Operation Canceled"
fi
