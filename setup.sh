#!/bin/bash

# Logo Artwork in ASCII
logoArt(){
	echo ""
	echo "  _____           _                                  _       ___    ___  "
	echo " |  __ \         | |                                | |     |__ \  / _ \ "
	echo " | |__) | __ ___ | |_ ___ ______ _ __ ___   ___  ___| |__      ) || | | |"
	echo " |  ___/ __/ _ \| __/ _  \______|  _  _   \ / _ \/ _  _|  \  / / || | |  "
	echo " | |   | | | (_) | || (_) |     | | | | | |  __/\__ \ | | |  / /_ | |_| |"
	echo " |_|   |_|  \___/ \__\___/      |_| |_| |_|\___||___/_| |_| |____(_)___/ "
	echo ""
}

# Verify that some packages are installed
requirepackage(){
   if [ ! -z "$2" ]
      then
         ldconfig -p | grep $2 > /dev/null
      else
         which $1 > /dev/null
   fi
   if [ $? != 0 ]
      then
         echo "Package $1: Installing..."
         apt-get install --assume-yes $1 > /dev/null
         echo "Package $1: Complete."
      else
         echo "Package $1: Already installed."
   fi
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

echo "Intiailzing..."

echo "Copying Files..."
sudo cp -rf proto-mesh /etc/proto-mesh

# Generate Config if Necessary
if [ ! -f /etc/proto-mesh/config ]
then
    echo "Generating Config File ..."
    sudo cp /etc/proto-mesh/config.sample /etc/proto-mesh/config
fi

# Generate Ethernet Config if Necessary
if [ ! -f /etc/proto-mesh/channel/.eth/config ]
then
    echo "Generating Ethernet Config File ..."
    sudo cp /etc/proto-mesh/channels/.eth/config.sample /etc/proto-mesh/channels/.eth/config
fi

# Generate WiFi Config if Necessary
if [ ! -f /etc/proto-mesh/channel/.wifi/config ]
then
    echo "Generating Wifi Config File ..."
    sudo cp /etc/proto-mesh/channels/.wifi/config.sample  /etc/proto-mesh/channels/.wifi/config
fi

echo "Installing Pre-Reqs ..."

#Install Required Packages
requirepackage python-simplejson
requirepackage python-qt4
requirepackage libssl-dev
requirepackage python-twisted-conch
requirepackage automake
requirepackage autoconf
requirepackage gcc
requirepackage uml-utilities
requirepackage build-essential
requirepackage pkg-config
requirepackage linux-headers-3.10-3-rpi

# Enable the openvswitch kernel module
modprobe openvswitch
if [ $? != 0 ]
then
   echo "Installing OpenvSwitch this may take some time..."
   sleep 2
   cd ~
   #Get OpenVSwitch LTS
   wget http://openvswitch.org/releases/openvswitch-2.5.4.tar.gz
   tar -xvzf openvswitch-2.5.4.tar.gz
   sudo rm -rf openvswitch-2.5.4.tar.gz
   cd openvswitch-2.5.4
   #Build Kernel Module
   sudo ./configure --with-linux=/lib/modules/3.10-3-rpi/build
   sudo make
   sudo make install
   #Install module
   cd datapath/linux/
   sudo modprobe openvswitch
   #Create Config
   sudo touch /usr/local/etc/ovs-vswitchd.conf
   sudo mkdir -p /usr/local/etc/openvswitch
   #Go Back 2 Directories
   cd ../../
   #Create DB
   sudo ovsdb-tool create /usr/local/etc/openvswitch/conf.db vswitchd/vswitch.ovsschema
else
	echo "OpenvSwitch Already Installed! Skipping ..."
fi

#Make Start/Stop Scripts Executable
echo "Setting Permissions..."
sudo chmod +x /etc/proto-mesh/start.sh
sudo chmod +x /etc/proto-mesh/shutdown.sh

echo "Setup Complete!"
echo "Please Reboot to use Proto-Mesh 2.0 ..."
