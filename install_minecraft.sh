#!/bin/sh
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

echo oracle-java7-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections

while ! echo y | apt-get install -y oracle-java7-installer; do
    sleep 10
    apt-get install -y oracle-java7-installer
done

adduser --system --no-create-home --home /srv/minecraft-server minecraft
addgroup --system minecraft
adduser minecraft minecraft
mkdir /srv/minecraft_server
cd /srv/minecraft_server

while ! echo y | wget https://s3.amazonaws.com/Minecraft.Download/versions/1.8/minecraft_server.1.8.jar; do
    sleep 10
    wget https://s3.amazonaws.com/Minecraft.Download/versions/1.8/minecraft_server.1.8.jar
done

chown -R minecraft /srv/minecraft_server

totalMem=$(free -m | awk '/Mem:/ { print $2 }')
if [ $totalMem -lt 1024 ]; then
    memoryAlloc=512m
else
    memoryAlloc=1024m
fi

touch /srv/minecraft_server/eula.txt
sh -c "echo 'eula=true' >> /srv/minecraft_server/eula.txt"

touch /etc/init/minecraft-server.conf
sh -c "echo 'start on runlevel [2345]' >> /etc/init/minecraft-server.conf"
sh -c "echo 'stop on runlevel [^2345]' >> /etc/init/minecraft-server.conf"
sh -c "echo 'console log' >> /etc/init/minecraft-server.conf"
sh -c "echo 'chdir /srv/minecraft_server' >> /etc/init/minecraft-server.conf"
sh -c "echo 'setuid minecraft' >> /etc/init/minecraft-server.conf"
sh -c "echo 'setgid minecraft' >> /etc/init/minecraft-server.conf"
sh -c "echo 'respawn' >> /etc/init/minecraft-server.conf"
sh -c "echo 'respawn limit 20 5' >> /etc/init/minecraft-server.conf"
printf 'exec /usr/bin/java -Xms%s -Xmx%s -jar minecraft_server.1.8.jar nogui' $memoryAlloc $memoryAlloc >> /etc/init/minecraft-server.conf

UUID="`wget -q  -O - http://api.ketrwu.de/$1`"
sh -c "echo '[\n {\n  \"uuid\":\"$UUID\",\n  \"name\":\"$1\",\n  \"level\":4\n }\n]' >> /srv/minecraft_server/ops.json"

start minecraft-server
