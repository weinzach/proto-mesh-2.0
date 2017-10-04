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

# Enable the openvswitch kernel module
modprobe openvswitch
if [ $? != 0 ]
then
	echo "OpenvSwitch isn't setup correctly..."
	echo "Try reinstalling Proto-Mesh 2.0 with the -f flag!"
	exit
fi

# Verify that the config file exists
if [ ! -f /etc/proto-mesh/config ]; then
    echo 'config file not present! Aborting.'
    exit
fi

# Load settings
. /etc/proto-mesh/config

logoArt

echo "Starting OpenvSwitch..."
ovsdb-server --remote=punix:/usr/local/var/run/openvswitch/db.sock \
                     --remote=db:Open_vSwitch,Open_vSwitch,manager_options \
                     --private-key=db:Open_vSwitch,SSL,private_key \
                     --certificate=db:Open_vSwitch,SSL,certificate \
                     --bootstrap-ca-cert=db:Open_vSwitch,SSL,ca_cert \
                     --pidfile --detach
ovs-vsctl --no-wait init
ovs-vswitchd --pidfile --detach
ovs-vsctl show

echo "Creating Open_vSwitch Interface..."
#Create Switch Port
sudo ovs-vsctl add-br br0

echo "Bonding Interface..."
sudo ovs-vsctl add-port br0 wlan0
sudo ifconfig wlan0 0 up


echo "Proto-Mesh 2.0 is Running!"
