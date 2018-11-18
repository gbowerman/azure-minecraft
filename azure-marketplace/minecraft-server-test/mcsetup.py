#!/usr/bin/env python3
'''gmcsetup.py
      - script to handle the config specific aspects of Minecraft server instance setup
      - assumes /srv/minecraft_server directory is already created
      - creates ops.json, whitelist.json, server.properties using the Azure VM tag values 
      - designed to be called from the shell script that sets up the service
'''
import json
import requests

def main():
    '''
    # debug - switch this code back in when deploying on Azure VM
    # VM tags from instance metadata endpoint
    endpoint = "http://169.254.169.254/metadata/instance/compute?api-version=2017-08-01"
    headers={'Metadata': 'True'}
    data_dict = requests.get(endpoint, headers=headers).json()
    tag_string = data_dict['tags']
    '''
    tag_string = 'difficulty:1;enablecommandblock:true;gamemode:0;generatestructures:true;levelname:world;levelseed:olives;minecraftuser:bugthing;spawnmonsters:true;whitelist:true'
    
    MOJANG_URL = 'https://api.mojang.com/users/profiles/minecraft/'
    MCFOLDER = '/srv/minecraft_server/'

    # get custom settings from tag_string list
    # convert string from 'valname1:val1;valname2:val2' format to dictionary
    tag_list = tag_string.split(';')
    tag_dict = {}
    for value in tag_list:
        val_list = value.split(':')
        tag_dict[val_list[0]] = val_list[1]

    # convert Minecraft username to GUID using the Mojang API
    api_url = MOJANG_URL + tag_dict['minecraftuser']
    guid_dict = requests.get(api_url).json()
    guid_str = guid_dict['id']
    # convert to 8-4-4-4-12 format
    uuid_str = '-'.join([guid_str[:8], guid_str[8:12], guid_str[12:16], guid_str[16:20], guid_str[20:32]])

    # print ops.json file
    ops_str = '[\n {\n  "uuid":"' + uuid_str + '",\n  \"name\":"' + tag_dict['minecraftuser'] + '",\n  "level":4\n }\n]'
    opsfile_str = MCFOLDER + 'ops.json'
    opsfile = open(opsfile_str,'w')
    opsfile.write(ops_str)
    opsfile.close()

    # print server.properties file
    srv_str = '\n'.join(["difficulty=" + tag_dict['difficulty'],
                        "level-name=" + tag_dict['levelname'],
                        "gamemode=" + tag_dict['gamemode'],
                        "white-list=" + tag_dict['whitelist'],
                        "enable-command-block=" + tag_dict['enablecommandblock'],
                        "spawn-monsters=" + tag_dict['spawnmonsters'],
                        "generate-structures=" + tag_dict['generatestructures'],
                        "level-seed=" + tag_dict['levelseed'] + "\n"])
    srvfile_str = MCFOLDER + 'server.properties'
    srvfile = open(srvfile_str,'w')
    srvfile.write(srv_str)
    srvfile.close()


if __name__ == "__main__":
    main()


