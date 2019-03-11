#!/usr/bin/env python3
'''gmcsetup.py
      - script to handle the config specific aspects of Minecraft server instance setup
      - assumes /srv/minecraft_server directory is already created
      - creates ops.json, whitelist.json, server.properties using the Azure VM tag values 
      - designed to be called from the shell script that sets up the service
'''
import os
import requests
from psutil import virtual_memory


def write_file(filepath, filetext):
    '''Create a file, write to it, close it'''
    newfile = open(filepath, 'w')
    newfile.write(filetext)
    newfile.close()


def main():
    # constants
    IMS_ENDPOINT = "http://169.254.169.254/metadata/instance/compute?api-version=2017-08-01"
    MOJANG_URL = 'https://api.mojang.com/users/profiles/minecraft/'
    SERVER_URL = 'https://minecraft.net/en-us/download/server/'
    MCFOLDER = '/srv/minecraft_server/'
    SERVICE_PATH = '/etc/systemd/system/minecraft-server.service'

    # Extract VM tags from instance metadata endpoint
    headers = {'Metadata': 'True'}
    data_dict = requests.get(IMS_ENDPOINT, headers=headers).json()
    tag_string = data_dict['tags']

    # get custom settings from tag_string list
    # convert string from 'valname1:val1;valname2:val2' format to dictionary
    tag_list = tag_string.split(';')
    tag_dict = {}
    for value in tag_list:
        val_list = value.split(':')
        tag_dict[val_list[0]] = val_list[1]

    # get the server download landing page
    download_page = requests.get(SERVER_URL).text

    # extract the server jar URL
    dl_idx = download_page.find('https://launcher')
    url_substr = download_page[dl_idx:]
    dl_end = url_substr.find('"')
    dl_url = url_substr[:dl_end]

    # download the server, write it to file
    jar_filename = f"{MCFOLDER}server.jar"
    with open(jar_filename, "wb") as jarfile:
        mc_jar = requests.get(dl_url)
        jarfile.write(mc_jar.content)
        jarfile.close()

    # convert Minecraft username to GUID using the Mojang API
    api_url = MOJANG_URL + tag_dict['minecraftuser']
    guid_dict = requests.get(api_url).json()
    guid_str = guid_dict['id']
    # convert to 8-4-4-4-12 format
    uuid_str = f"{guid_str[:8]}-{guid_str[8:12]}-{guid_str[12:16]}-{guid_str[16:20]}-{guid_str[20:32]}"

    # print ops.json file
    ops_str = f'[\n {{\n  "uuid":"{uuid_str}",\n  "name":"{tag_dict["minecraftuser"]}",\n  "level":4\n }}\n]'
    write_file(f'{MCFOLDER}ops.json', ops_str)

    # print server.properties file
    srv_str = f"""difficulty={tag_dict['difficulty']}
level-name={tag_dict['levelname']}
gamemode={tag_dict['gamemode']}
white-list={tag_dict['whitelist']}
enable-command-block={tag_dict['enablecommandblock']}
spawn-monsters={tag_dict['spawnmonsters']}
generate-structures={tag_dict['generatestructures']}
level-seed={tag_dict['levelseed']}
"""
    write_file(f'{MCFOLDER}server.properties', srv_str)

    # create a service and set the permissions
    # 1st check physical memory is > 1GB else lower heap size..
    mem = virtual_memory()
    if mem.total <= 1024 * 1024 * 1024:
        heapargs = "-Xms512m -Xmx1g"
    else:
        heapargs = "-Xms1g -Xmx2g"

    # now create the service file
    service_str = f"""[Unit]
Description=Minecraft Service
After=rc-local.service
[Service]
WorkingDirectory={MCFOLDER}
ExecStart=/usr/bin/java {heapargs} -jar {jar_filename}
ExecReload=/bin/kill -HUP $MAINPID
KillMode=process
Restart=on-failure
[Install]
WantedBy=multi-user.target
Alias=minecraft.service
"""
    write_file(SERVICE_PATH, service_str)
    os.chmod(SERVICE_PATH, 0o664)

    # create the uela file
    write_file(f"{MCFOLDER}eula.txt", f"eula=true")


if __name__ == "__main__":
    main()
