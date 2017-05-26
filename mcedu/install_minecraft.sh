#!/bin/bash
# Custom Minecraft PE server install script for Ubuntu 16.04-LTS
# $1 = XUID
# $2 = difficulty
# $3 = level-name
# $4 = gamemode
# $5 = white-list
# $6 = level-seed

# basic service and API settings
minecraft_root_path=/srv/minecraft_server
minecraft_server_path=$minecraft_root_path/dedicated_server/output
minecraft_user=minecraft
minecraft_group=minecraft

# install required software (unzip and libcurl4)
while ! echo y | apt-get update; do
    sleep 10
    apt-get update
done

while ! echo y | apt-get install -y unzip; do
    sleep 10
    apt-get install -y unzip
done

while ! echo y | apt-get install -y libcurl4-openssl-dev; do
    sleep 10
    apt-get install -y libcurl4-openssl-dev
done

# create user and install folder
adduser --system --no-create-home --home /srv/minecraft-server $minecraft_user
addgroup --system $minecraft_group
mkdir $minecraft_root_path
cd $minecraft_root_path

# set permissions on install folder
chown -R $minecraft_user $minecraft_root_path

# get and unzip the server zip file
curl "https://github.com/gbowerman/azure-minecraft/blob/master/mcedu/server/dedicated_server.zip?raw=true" > $minecraft_root_path/dedicated_server.zip
unzip $minecraft_root_path/dedicated_server.zip -d $minecraft_root_path
chmod +x $minecraft_server_path/mcpe_server

# create a launch file
touch $minecraft_server_path/launch.sh
printf 'cd %s\n' $minecraft_server_path >> $minecraft_server_path/launch.sh
printf 'export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:%s\n' $minecraft_server_path >> $minecraft_server_path/launch.sh
printf './mcpe_server' >> $minecraft_server_path/launch.sh
chmod +x $minecraft_server_path/launch.sh

# create a service
touch /etc/systemd/system/minecraft-server.service
printf '[Unit]\nDescription=Minecraft Service\nAfter=rc-local.service\n' >> /etc/systemd/system/minecraft-server.service
printf '[Service]\nWorkingDirectory=%s\n' $minecraft_server_path >> /etc/systemd/system/minecraft-server.service
printf 'ExecStart=%s/launch.sh\n' $minecraft_server_path >> /etc/systemd/system/minecraft-server.service
printf 'ExecReload=/bin/kill -HUP $MAINPID\nKillMode=process\nRestart=on-failure\n' >> /etc/systemd/system/minecraft-server.service
printf '[Install]\nWantedBy=multi-user.target\nAlias=minecraft-server.service' >> /etc/systemd/system/minecraft-server.service
chmod +x /etc/systemd/system/minecraft-server.service

# create and set permissions on user access JSON files
touch $minecraft_server_path/whitelist.json
printf '[\n {\n  \"xuid\":\"%s\", \"ignoresPlayerLimit\":true\n }\n]' $1 >> $minecraft_server_path/whitelist.json
chown $minecraft_user:$minecraft_group $minecraft_server_path/whitelist.json

# create a valid operators file using the Mojang API
touch $minecraft_server_path/ops.json
printf '[\n {\n  \"xuid\":\"%s\"\n }\n]' $1 >> $minecraft_server_path/ops.json
chown $minecraft_user:$minecraft_group $minecraft_server_path/ops.json

# set user preferences in server.properties
touch $minecraft_server_path/server.properties
chown $minecraft_user:$minecraft_group $minecraft_server_path/server.properties
printf 'difficulty=%s\n' $2 >> $minecraft_server_path/server.properties
printf 'level-name=%s\n' $3 >> $minecraft_server_path/server.properties
printf 'gamemode=%s\n' $4 >> $minecraft_server_path/server.properties
printf 'white-list=%s\n' $5 >> $minecraft_server_path/server.properties
printf 'level-seed=%s\n' $6 >> $minecraft_server_path/server.properties

systemctl start minecraft-server
