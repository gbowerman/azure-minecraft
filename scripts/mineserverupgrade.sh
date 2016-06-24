#!/bin/bash
# Minecraft server upgrade script for Azure
# $1 = new version (e.g. 1.10)

# check for a command line argument
if [[ ! $# -eq 1 ]] ; then
    echo The Minecraft server version needs to be passed as a command line argument, e.g. sudo $0 1.10
    exit 1
fi

# server values
minecraft_server_path=/srv/minecraft_server
server_jar=minecraft_server.$1.jar
SERVER_JAR_URL=https://s3.amazonaws.com/Minecraft.Download/versions/$1/minecraft_server.$1.jar

# adjust memory usage depending on VM size
totalMem=$(free -m | awk '/Mem:/ { print $2 }')
if [ $totalMem -lt 1024 ]; then
    memoryAlloc=512m
else
    memoryAlloc=1024m
fi

cd $minecraft_server_path

# download the server jar
while ! echo y | wget $SERVER_JAR_URL; do
    sleep 10
    wget $SERVER_JAR_URL
done

systemctl stop minecraft-server
# move the old service file
mv /etc/systemd/system/minecraft-server.service /tmp/minecraft-server.service.old

# recreate the service
touch /etc/systemd/system/minecraft-server.service
printf '[Unit]\nDescription=Minecraft Service\nAfter=rc-local.service\n' >> /etc/systemd/system/minecraft-server.service
printf '[Service]\nWorkingDirectory=%s\n' $minecraft_server_path >> /etc/systemd/system/minecraft-server.service
printf 'ExecStart=/usr/bin/java -Xms%s -Xmx%s -jar %s/%s nogui\n' $memoryAlloc $memoryAlloc $minecraft_server_path $server_jar >> /etc/systemd/system/minecraft-server.service
printf 'ExecReload=/bin/kill -HUP $MAINPID\nKillMode=process\nRestart=on-failure\n' >> /etc/systemd/system/minecraft-server.service
printf '[Install]\nWantedBy=multi-user.target\nAlias=minecraft-server.service' >> /etc/systemd/system/minecraft-server.service

# restart the service
systemctl start minecraft-server

# closing message
echo Upgrade completed. If any problems, you can revert to the previous version by running\:
echo sudo systemctl stop minecraft-server
echo sudo cp /tmp/minecraft-server.service.old /etc/systemd/system/minecraft-server.service
systemctl daemon-reload
echo sudo systemctl start minecraft-server
