![Logo](logo.png)

Introduction
============
This repository is intended to make the process of setting
up a wireless mesh network on a Raspberry Pi 3 very very easy.

Installation
============
To setup the current system to run this mesh software at startup,
run `sudo chmod +x setup.sh` then `sudo ./setup.sh` in this directory. (This will gather all dependenices and generate config files for future use.)

Usage
=====
To start running the mesh software, simply execute `sudo sh /etc/proto-mesh/start.sh` 
in this directory (the same directory as this README). If there are other 
mesh nodes in wireless range, you should now be connected to them. Use 
`sudo sh /etc/proto-mesh/shutdown.sh` to properly disable your connection to the mesh.


Configuration
==============
The "config" file in this directory can be used to change the mesh
settings for this node including the network interface and channel. Specifically, you may want to consider changing
the `HOSTNAME` field to something unique. This name can be used to reference
this node by all other nodes on the network. For example if you set `HOSTNAME`
line to read,

    HOSTNAME='foo-pi.p2p'

then another nodes in the network should be able to ping this one with,

    ping foo-pi.p2p

NOTE: 
The contents and formatting of "config" are likely to change in future 
updates, but the rest of the commands mentioned in this README should continue 
to be supported indefinitely.

