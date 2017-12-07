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

function ifup {
    if [[ ! -d /sys/class/net/${1} ]]; then
        printf 'No such interface: %s\n' "$1" >&2
        return 1
    else
        [[ $(</sys/class/net/${1}/operstate) == up ]]
    fi
}


# Verify that the config files exist
if [ ! -f /opt/proto-mesh/config ]; then
    echo 'config file not present! Aborting.'
    exit
fi

if [ ! -f /opt/proto-mesh/cjdns/cjdroute.conf ]; then
    echo 'CJDNS Config not present! Configuring...'
	cd /opt/proto-mesh/
	cd cjdns
	sudo ./cjdroute --genconf >> cjdroute.conf
	sleep 1
fi

logoArt

# Try to kill NetworkManager
sudo service NetworkManager stop
  
# Load settings
source /opt/proto-mesh/config

echo "Launching Mesh Interface..."
if [[ $WIFI_MESH = 'yes' ]];
then
  sudo systemctl stop dhcpcd.service
  sudo ip link set down dev $DEFAULT_WIFI_IFACE
  sudo ifconfig $DEFAULT_WIFI_IFACE down
  sleep 2
  sudo iwconfig $DEFAULT_WIFI_IFACE mode ad-hoc
  sudo iwconfig $DEFAULT_WIFI_IFACE channel $WIFI_CHANNEL
  sudo iwconfig $DEFAULT_WIFI_IFACE essid $WIFI_ESSID
  ip link set up dev $DEFAULT_WIFI_IFACE
  sudo ifconfig $DEFAULT_WIFI_IFACE 0 up
  sudo avahi-autoipd -D wlan0
  sleep 1
  sudo systemctl start dhcpcd.service
fi

echo "Starting CJDNS..."
cd /opt/proto-mesh/cjdns
sudo ./cjdroute < cjdroute.conf > cjdroute.log

sleep 3
echo "Proto-Mesh 2.0 is Running!"
