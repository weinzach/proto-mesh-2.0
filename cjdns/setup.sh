#!/bin/bash

# Get board information and set flags accordingly
BOARD_FAMILY="Raspberry Pi"
BOARD_NAME="Generic"
CJDNS_BUILD_CMD="sudo Seccomp_NO=1 NO_NEON=1 ./do"
BOARD_HARDWARE=$(cat /proc/cpuinfo  | grep Hardware | awk '{print $3}' | head -n 1)

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
sudo cp -rf bin /opt/proto-mesh

# Generate Config if Necessary
if [ ! -f /opt/proto-mesh/config ]
then
    echo "Generating Config File ..."
    sudo cp /opt/proto-mesh/config.sample /opt/proto-mesh/config
fi

echo "Installing Pre-Reqs ..."

#Update Repositories
sudo apt-get update

#Install Required Packages
requirepackage git
requirepackage build-essential
requirepackage avahi-autoipd

#Setup NodeJs 8.x
if which nodejs > /dev/null
	then
		echo "NodeJS is installed, skipping..."
    else
		curl -sL https://deb.nodesource.com/setup_8.x | sudo -E bash -
		sudo apt-get install -y nodejs
    fi

if which npm > /dev/null
	then
		echo "NPM is installed, skipping..."
    else
		curl -sL https://deb.nodesource.com/setup_8.x | sudo -E bash -
		sudo apt-get install -y nodejs
    fi

cd /opt/proto-mesh/
sudo git clone https://github.com/cjdelisle/cjdns.git cjdns
cd cjdns

BOARD_REVISION=`sed -rn 's/Revision\s+\:\s+([0-9a-z_\-\s\,\(\)]+)/\1/p' /proc/cpuinfo`
if [[ $BOARD_REVISION == *"900092"* || $BOARD_REVISION == *"900093"* || $BOARD_REVISION == *"9000c1"* ]]; then
    BOARD_NAME="Zero"
    CJDNS_BUILD_CMD="sudo Seccomp_NO=1 NO_NEON=1 CFLAGS=\"-s -static -Wall -mcpu=arm1176jzf-s -mfpu=vfp -mfloat-abi=hard\" ./do"
elif [[ $BOARD_REVISION == *"00"* ]]; then
    BOARD_NAME="1"
    CJDNS_BUILD_CMD="sudo Seccomp_NO=1 NO_NEON=1 NO_TEST=1 CFLAGS=\"-s -static -Wall\" ./do"
elif [[ $BOARD_REVISION == *"a01041"* || $BOARD_REVISION == *"a21041"* ]]; then
    BOARD_NAME="2"
    CJDNS_BUILD_CMD="sudo Seccomp_NO=1 CFLAGS=\"-s -static -Wall -mfpu=neon -mcpu=cortex-a7 -mtune=cortex-a7 -fomit-frame-pointer -marm\" ./do"
elif [[ $BOARD_REVISION == *"a02082"* || $BOARD_REVISION == *"a22082"* ]]; then
    BOARD_NAME="3"
    CJDNS_BUILD_CMD="sudo Seccomp_NO=1 CFLAGS="-s -static -Wall -mfpu=neon -mcpu=cortex-a7 -mtune=cortex-a7 -fomit-frame-pointer -marm" ./do"
fi

echo -e "\e[1;32mCompiling CJDNS for ${BOARD_FAMILY} ${BOARD_NAME} (${BOARD_REVISION})...\e[0m"
$CJDNS_BUILD_CMD
sudo ./cjdroute --genconf >> cjdroute.conf

cd /opt/proto-mesh/
cd utils
sudo npm install

#Make Start/Stop Scripts Executable
echo "Setting Permissions..."
sudo chmod +x /opt/proto-mesh/start.sh
sudo chmod +x /opt/proto-mesh/shutdown.sh

#Generate Service File
sudo cp /opt/proto-mesh/utils/protomesh.service /etc/systemd/system/protomesh.service
sudo systemctl daemon-reload

#Prompt for Boot
read -p "Start Proto-Mesh on Boot (Y/n)? " CONT
CONT=${CONT,,} # tolower
if [ "$CONT" = "n" ]; then
  sudo systemctl disable protomesh.service
else
  sudo systemctl enable protomesh.service
fi

echo "Setup Complete!"
echo "Please Reboot to use Proto-Mesh 2.0 ..."
