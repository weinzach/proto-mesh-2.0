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
curl -sL https://deb.nodesource.com/setup_8.x | sudo -E bash -
sudo apt-get install -y nodejs

cd /opt/proto-mesh/
sudo git clone https://github.com/cjdelisle/cjdns.git cjdns
cd cjdns
sudo ./do
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
