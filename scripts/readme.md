# Minecraft script repo

Collection of Minecraft related scripts 

To use these scripts save them as a file on your Linux machine and make them executable (chmod +x filename).

## mineuuid.sh

Converts a Minecraft user name to its corresponding UUID. This can be useful when automating setup of Minecraft servers and you want to write out an operators or whitelist file for example.

The script calls the Mojang API, so you need access to the internet. It also needs to run in the bash shell.

Usage: mineuuid.sh minecraft_user

Example:
./mineuuid.sh notch

069a79f4-44e9-4726-a5be-fca90e38aaf5

## mineserverupgrade.sh

Upgrades an existing Azure Minecraft server to a newer version. Could also be used to downgrade.

Example:
sudo ./mineserverupgrade.sh 1.10



