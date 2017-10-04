#!/bin/bash

if [ "$(whoami)" != "root" ] ; then
   echo "Please run as root!"
   exit
fi

#Prompt to Confirm
read -p "Are you sure you wish to remove Proto-Mesh 2.0 (Y/n)? " CONT
if [ "$CONT" = "Y" ]; then
  echo "Disabling Proto-Mesh 2.0 Services..."
  sudo sh /etc/proto-mesh/shutdown.sh
  #Uninstall /etc/proto-mesh directory
  echo "Removing Uncescessary Files..."
  sudo rm -rf /etc/proto-mesh
  #Report done
  echo "Done! Proto-Mesh 2.0 has been removed."
else
  #Report nothing has happened
  echo "Operation Canceled"
fi
