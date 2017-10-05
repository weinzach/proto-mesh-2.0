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

logoArt

# Try to kill NetworkManager
sudo service NetworkManager stop

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
sudo ovs-vsctl del-br br0
sleep 1
sudo ovs-vsctl add-br br0
  
# Load settings
source /etc/proto-mesh/config

echo "Bonding Interface..."
if [[ $WIFI_MESH = 'yes' ]];
then
  sudo ip link set down dev $DEFAULT_WIFI_IFACE
  sudo ifconfig $DEFAULT_WIFI_IFACE down
  sleep 2
  sudo iwconfig $DEFAULT_WIFI_IFACE mode ad-hoc
  sudo iwconfig $DEFAULT_WIFI_IFACE channel $WIFI_CHANNEL
  sudo iwconfig $DEFAULT_WIFI_IFACE essid $WIFI_ESSID
  ip link set up dev $DEFAULT_WIFI_IFACE
  sudo ovs-vsctl add-port br0 $DEFAULT_WIFI_IFACE
  sudo ifconfig $DEFAULT_WIFI_IFACE 0 up
  cd /etc/proto-mesh/utils
  python3 giveIPv4.py $DEFAULT_WIFI_IFACE br0
  cd ../
else
  sudo ip link set down dev $DEFAULT_ETHERNET_IFACE
  sudo ifconfig $DEFAULT_ETHERNET_IFACE down
  sleep 2
  ip link set up dev $DEFAULT_ETHERNET_IFACE
  sudo ovs-vsctl add-port br0 $DEFAULT_ETHERNET_IFACE
  sudo ifconfig $DEFAULT_ETHERNET_IFACE 0 up
  cd /etc/proto-mesh/utils
  python3 giveIPv4.py $DEFAULT_ETHERNET_IFACE br0
  cd ../
fi

echo "Proto-Mesh 2.0 is Running!"
