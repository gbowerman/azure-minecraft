#!/usr/bin/env python3
'''mcdownload.py
      - script to upgrade the Java server version of Minecraft installed from the Azure Marketplace
      - This version just upgrades to latest. Future versions might add a --version argument
'''
import os
import requests


def write_file(filepath, filetext):
    '''Create a file, write to it, close it'''
    newfile = open(filepath, 'w')
    newfile.write(filetext)
    newfile.close()


def main():
    # constants
    SERVER_URL = 'https://minecraft.net/en-us/download/server/'
    MCFOLDER = '/srv/minecraft_server/'

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

if __name__ == "__main__":
    main()