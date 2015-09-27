#!/bin/bash
# Custom Scriptcraft server install script for Ubuntu 15.04
# $1 = Minecraft user name

# basic service and API settings
scriptcraft_server_path=/srv/scriptcraft_server
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
adduser --system --no-create-home --home /srv/scriptcraft-server $minecraft_user
addgroup --system $minecraft_group
mkdir $scriptcraft_server_path
cd $scriptcraft_server_path

# download the server jar
while ! echo y | wget http://download.yiddish.ninja/CM1.2.1.zip; do
    sleep 10
    wget http://download.yiddish.ninja/CM1.2.1.zip
done

# set permissions on install folder
chown -R $minecraft_user $scriptcraft_server_path

# adjust memory usage depending on VM size
totalMem=$(free -m | awk '/Mem:/ { print $2 }')
if [ $totalMem -lt 1024 ]; then
    memoryAlloc=512m
else
    memoryAlloc=1024m
fi

# unzip the scriptcraft zip file
unzip CM1.2.1.zip

# create a service
touch /etc/systemd/system/minecraft-server.service
printf '[Unit]\nDescription=Minecraft Service\nAfter=rc-local.service\n' >> /etc/systemd/system/scriptcraft-server.service
printf '[Service]\nWorkingDirectory=%s\n' $scriptcraft_server_path >> /etc/systemd/system/scriptcraft-server.service
printf 'ExecStart=/usr/bin/java -Xms%s -Xmx%s -jar %s/CanaryMod-1.2.1.jar nogui\n' $memoryAlloc $memoryAlloc $scriptcraft_server_path >> /etc/systemd/system/scriptcraft-server.service
printf 'ExecReload=/bin/kill -HUP $MAINPID\nKillMode=process\nRestart=on-failure\n' >> /etc/systemd/system/scriptcraft-server.service
printf '[Install]\nWantedBy=multi-user.target\nAlias=scriptcraft-server.service' >> /etc/systemd/system/scriptcraft-server.service

# create a valid operators file using the Mojang API
mojang_output="`wget -qO- $UUID_URL`"
rawUUID=${mojang_output:7:32}
UUID=${rawUUID:0:8}-${rawUUID:8:4}-${rawUUID:12:4}-${rawUUID:16:4}-${rawUUID:20:12}
printf '<operators>\n  <tableProperties>\n    ' > $scriptcraft_server_path/db/operators.xml
printf '<id auto-increment=\"true\" data-type=\"INTEGER\" column-type=\"PRIMARY\" is-list=\"false\" not-null=\"false\" />\n' >> $scriptcraft_server_path/db/operators.xml
printf '    <player auto-increment=\"false\" data-type=\"STRING\" column-type=\"NORMAL\" is-list=\"false\" not-null=\"false\" />\n' >> $scriptcraft_server_path/db/operators.xml
printf '  </tableProperties>\n  <entry>\n' >> $scriptcraft_server_path/db/operators.xml
printf '    <id>1</id>\n    <player>%s</player>\n' $UUID >> $scriptcraft_server_path/db/operators.xml
printf '  </entry>\n</operators>' >> $scriptcraft_server_path/db/operators.xml
printf '%s' $1 >> $scriptcraft_server_path/config/ops.cfg

# create a valid whitelist file
printf '<whitelist>\n  <tableProperties>\n    ' > $scriptcraft_server_path/db/whitelist.xml
printf '<id auto-increment=\"true\" data-type=\"INTEGER\" column-type=\"PRIMARY\" is-list=\"false\" not-null=\"false\" />\n' >> $scriptcraft_server_path/db/whitelist.xml
printf '    <player auto-increment=\"false\" data-type=\"STRING\" column-type=\"NORMAL\" is-list=\"false\" not-null=\"false\" />\n' >> $scriptcraft_server_path/db/whitelist.xml
printf '  </tableProperties>\n  <entry>\n' >> $scriptcraft_server_path/db/whitelist.xml
printf '    <id>1</id>\n    <player>%s</player>\n' $UUID >> $scriptcraft_server_path/db/whitelist.xml
printf '    <uuid>%s</uuid>\n' $UUID >> $scriptcraft_server_path/db/whitelist.xml
printf '  </entry>\n</whitelist>' >> $scriptcraft_server_path/db/whitelist.xml

systemctl start scriptcraft-server
