#!/bin/bash

cd /etc/proto-mesh/cjdns/
sudo rm -rf cjdroute.conf
sudo ./cjdroute --genconf >> cjdroute.conf

echo "Renewed CJDNS Conf! Please reboot..."
