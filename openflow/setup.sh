#!/bin/bash

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

echo "Intiailzing..."

echo "Copying Files..."
sudo cp -rf bin /etc/proto-mesh

# Generate Config if Necessary
if [ ! -f /etc/proto-mesh/config ]
then
    echo "Generating Config File ..."
    sudo cp /etc/proto-mesh/config.sample /etc/proto-mesh/config
fi

echo "Installing Pre-Reqs ..."

#Update Repositories
sudo apt-get update

#Install Required Packages
requirepackage python3
requirepackage ip
requirepackage avahi-autoipd
requirepackage python-simplejson
requirepackage python-qt4
requirepackage libsodium-dev libsodium
requirepackage bridge-utils
requirepackage libssl-dev
requirepackage python-twisted-conch
requirepackage automake
requirepackage autoconf
requirepackage gcc
requirepackage uml-utilities
requirepackage build-essential
requirepackage pkg-config
requirepackage linux-headers-3.10-3-rpi

# Check for presence of OpenvSwitch with a command test
ovs-vsctl --help > /dev/null
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
