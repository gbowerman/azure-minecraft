#!/bin/bash
# Custom Minecraft server install script for Ubuntu 18.04

# basic service and API settings
minecraft_server_path=/srv/minecraft_server
PY_URL=https://raw.githubusercontent.com/gbowerman/azure-minecraft/master/azure-marketplace/minecraft-server-test/mcsetup.py

# update repos
while ! echo y | apt-get update; do
    sleep 10
    apt-get update
done

# Install Java
while ! echo y | apt install -y default-jre; do
    sleep 10
    apt install -y default-jre
done

# create user and install folder
mkdir $minecraft_server_path
adduser --system --no-create-home --home $minecraft_server_path minecraft
addgroup --system minecraft

cd $minecraft_server_path

# set permissions on install folder
chown -R $minecraft_user $minecraft_server_path

# set up ops & server.properties file, create service
curl $PY_URL > $minecraft_server_path/mcsetup.py
chmod +x $minecraft_server_path/mcsetup.py
$minecraft_server_path/mcsetup.py

systemctl start minecraft-server
systemctl enable minecraft-server
