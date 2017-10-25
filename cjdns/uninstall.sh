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

if [ "$(whoami)" != "root" ] ; then
   echo "Please run as root!"
   exit
fi

#Prompt to Confirm
read -p "Are you sure you wish to remove Proto-Mesh 2.0 (Y/n)? " CONT
if [ "$CONT" = "Y" ]; then
  logoArt
  echo "Disabling Proto-Mesh 2.0 Services..."
  
  #Stop service if running
  sudo systemctl stop protomesh.service
  sudo systemctl disable protomesh.service
  #Remove Service File
  sudo rm -rf /etc/systemd/system/protomesh.service
  #Reload Systemctl
  echo "Reloading Systemctl..."
  sudo systemctl daemon-reload
  
  #Uninstall /etc/proto-mesh directory
  echo "Removing Uncescessary Files..."
  sudo rm -rf /etc/proto-mesh
  #Report done
  echo "Done! Proto-Mesh 2.0 has been removed."
else
  #Report nothing has happened
  echo "Operation Canceled"
fi
