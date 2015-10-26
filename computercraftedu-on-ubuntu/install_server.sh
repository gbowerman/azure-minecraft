#!/bin/bash
# Custom Computercraftedu server install script for Ubuntu 15.04
# $1 = Minecraft user name

# basic service and API settings
compcraft_server_path=/srv/compcraft_server
minecraft_user=minecraft
minecraft_group=minecraft
UUID_URL=https://api.mojang.com/users/profiles/minecraft/$1

# add and update repos
while ! echo y | apt-get install -y software-properties-common; do
    sleep 10
    apt-get install -y software-properties-common
done

while ! echo y | apt-add-repository -y ppa:webupd8team/java; do
    sleep 10
    apt-add-repository -y ppa:webupd8team/java
done

while ! echo y | apt-get update; do
    sleep 10
    apt-get update
done

# Install Java8
echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections

while ! echo y | apt-get install -y oracle-java8-installer; do
    sleep 10
    apt-get install -y oracle-java8-installer
done

# install unzip
while ! echo y | apt-get install -y unzip; do
    sleep 10
    apt-get install -y unzip
done

# create user and install folder
adduser --system --no-create-home --home $compcraft_server_path $minecraft_user
addgroup --system $minecraft_group
mkdir $compcraft_server_path
cd $compcraft_server_path

# download the server and mod jar files
while ! echo y | wget http://computercraftedu.com/downloads/ComputerCraftPlusComputerCraftEdu1.74.jar; do
    sleep 10
    wget http://computercraftedu.com/downloads/ComputerCraftPlusComputerCraftEdu1.74.jar
done
while ! echo y | wget http://files.minecraftforge.net/maven/net/minecraftforge/forge/1.7.10-10.13.4.1517-1.7.10/forge-1.7.10-10.13.4.1517-1.7.10-installer.jar; do
    sleep 10
    wget http://files.minecraftforge.net/maven/net/minecraftforge/forge/1.7.10-10.13.4.1517-1.7.10/forge-1.7.10-10.13.4.1517-1.7.10-installer.jar
done

# set permissions on install folder
chown -R $minecraft_user $compcraft_server_path

# adjust memory usage depending on VM size
totalMem=$(free -m | awk '/Mem:/ { print $2 }')
if [ $totalMem -lt 1024 ]; then
    memoryAlloc=512m
else
    memoryAlloc=1024m
fi

# extract the forge jar file
/usr/bin/java -jar ./forge-1.7.10-10.13.4.1517-1.7.10-installer.jar --installServer

# create the uela file
touch $compcraft_server_path/eula.txt
echo 'eula=true' >> $compcraft_server_path/eula.txt

# add compcraftedu mod to mods folder
mkdir $compcraft_server_path/mods
chown $minecraft_user:$minecraft_group $compcraft_server_path/mods
mv ./ComputerCraftPlusComputerCraftEdu1.74.jar $compcraft_server_path/mods/.

# create a service
touch /etc/systemd/system/compcraft-server.service
printf '[Unit]\nDescription=ComputerCraftEdu Service\nAfter=rc-local.service\n' >> /etc/systemd/system/compcraft-server.service
printf '[Service]\nWorkingDirectory=%s\n' $compcraft_server_path >> /etc/systemd/system/compcraft-server.service
printf 'ExecStart=/usr/bin/java -Xms%s -Xmx%s -jar %s/forge-1.7.10-10.13.4.1517-1.7.10-universal.jar nogui\n' $memoryAlloc $memoryAlloc $compcraft_server_path >> /etc/systemd/system/compcraft-server.service
printf 'ExecReload=/bin/kill -HUP $MAINPID\nKillMode=process\nRestart=on-failure\n' >> /etc/systemd/system/compcraft-server.service
printf '[Install]\nWantedBy=multi-user.target\nAlias=compcraft-server.service' >> /etc/systemd/system/compcraft-server.service

# create and set permissions on user access JSON files
touch $compcraft_server_path/banned-players.json
chown $minecraft_user:$minecraft_group $compcraft_server_path/banned-players.json
touch $compcraft_server_path/banned-ips.json
chown $minecraft_user:$minecraft_group $compcraft_server_path/banned-ips.json
touch $compcraft_server_path/whitelist.json
chown $minecraft_user:$minecraft_group $compcraft_server_path/whitelist.json

# create a valid operators file using the Mojang API
mojang_output="`wget -qO- $UUID_URL`"
rawUUID=${mojang_output:7:32}
UUID=${rawUUID:0:8}-${rawUUID:8:4}-${rawUUID:12:4}-${rawUUID:16:4}-${rawUUID:20:12}
printf '[\n {\n  \"uuid\":\"%s\",\n  \"name\":\"%s\",\n  \"level\":4\n }\n]' $UUID $1 >> $compcraft_server_path/ops.json
chown $minecraft_user:$minecraft_group $compcraft_server_path/ops.json

systemctl start compcraft-server
