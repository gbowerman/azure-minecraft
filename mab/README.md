# MAB - Minecraft Azure Bridge
A project to represent Azure cloud infrastructure in Minecraft.

## How it works

## Setup instructions
- Set up a Linux VM running Minecraft (tested with Ubuntu 18.04-LTS)
- Copy mab.py locally
- Edit .env in the same folder as map.py to set up Azure service principal credentials
- Edit service.mab to reflect mab.py location
- Copy service.mab to /etc/systemd/system/mab.service
- sudo systemctl start mab


