#!/bin/bash
# stop the existing minecraft server
service minecraft-server stop

# delete earlier server versions if present
rm server.jar.old

# backup current server version
cp server.jar server.jar.old

# download  latest server version
python3 ./mcdownload.py

# start Minecraft server
service minecraft-server start