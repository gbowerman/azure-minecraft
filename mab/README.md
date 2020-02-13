# MAB - Minecraft Azure Bridge
A project to represent Azure cloud infrastructure in Minecraft.

## How it works
MAB runs as a Linux background service monitoring Azure Cloud Infrastructure and representing it in the form of of Minecraft functions. You can run the functions manually in Minecraft or set them to be trigger by a pressure plate etc.

## Setup instructions
- Set up a Linux VM running Minecraft (tested with Ubuntu 18.04-LTS)
- Copy mab.py locally
- Edit .env in the same folder as map.py to set up Azure service principal credentials
- Edit service.mab to reflect mab.py location
- Copy service.mab to /etc/systemd/system/mab.service
- sudo systemctl start mab
- Copy datapacks folder and the files under it to your Mincecraft world folder
- In minecraft run /reload to refresh the functions (which are updated in a loop by the mab service)
- The buildc function will create a visualization of an empty data center in your world - you may need to experiment with the relative height and distance offsets in mab.py to get this working correctly. You'll also need a large flat plane in your world to work on.
