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

# Verify that the config file exists
if [ ! -f /opt/proto-mesh/config ]; then
    echo 'config file not present! Aborting.'
    exit
fi

# Load settings
. /opt/proto-mesh/config

logoArt

echo "Unloading mesh interface ..."
sudo ifconfig wlan0 0 down

echo "Killing CJDNS Processes ..."
sudo killall cjdroute

echo "Proto-Mesh 2.0 has been shutdown cleanly!"

