#!/bin/bash
# Custom Minecraft server install script for Ubuntu 18.04

# basic service and API settings
minecraft_server_path=/srv/minecraft_server
minecraft_user=minecraft
minecraft_group=minecraft
UUID_URL=https://api.mojang.com/users/profiles/minecraft/$1
PY_URL=https://raw.githubusercontent.com/gbowerman/azure-minecraft/master/azure-marketplace/minecraft-server-test/mcsetup.py

# screen scrape the server jar location from the Minecraft server download page
SERVER_JAR_URL=`curl https://minecraft.net/en-us/download/server/ | grep 'Download <a' | cut -d '"' -f2`
server_jar=server.jar

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
adduser --system --no-create-home --home $minecraft_server_path $minecraft_user
addgroup --system $minecraft_group

cd $minecraft_server_path

# download the server jar
while ! echo y | wget $SERVER_JAR_URL; do
    sleep 10
    wget $SERVER_JAR_URL
done

# set permissions on install folder
chown -R $minecraft_user $minecraft_server_path

# adjust memory usage depending on VM size
totalMem=$(free -m | awk '/Mem:/ { print $2 }')
if [ $totalMem -lt 2048 ]; then
    memoryAllocs=512m
    memoryAllocx=1g
else
    memoryAllocs=1g
    memoryAllocx=2g
fi

# create the uela file
touch $minecraft_server_path/eula.txt
echo 'eula=true' >> $minecraft_server_path/eula.txt

# set up ops and server.properties file
curl $PY_URL > $minecraft_server_path/mcsetup.py
chmod +x $minecraft_server_path/mcsetup.py
$minecraft_server_path/mcsetup.py

# create a service
touch /etc/systemd/system/minecraft-server.service
printf '[Unit]\nDescription=Minecraft Service\nAfter=rc-local.service\n' >> /etc/systemd/system/minecraft-server.service
printf '[Service]\nWorkingDirectory=%s\n' $minecraft_server_path >> /etc/systemd/system/minecraft-server.service
printf 'ExecStart=/usr/bin/java -Xms%s -Xmx%s -jar %s/%s nogui\n' $memoryAllocs $memoryAllocx $minecraft_server_path $server_jar >> /etc/systemd/system/minecraft-server.service
printf 'ExecReload=/bin/kill -HUP $MAINPID\nKillMode=process\nRestart=on-failure\n' >> /etc/systemd/system/minecraft-server.service
printf '[Install]\nWantedBy=multi-user.target\nAlias=minecraft.service' >> /etc/systemd/system/minecraft-server.service
chmod +x /etc/systemd/system/minecraft-server.service

systemctl start minecraft-server
systemctl enable minecraft-server
