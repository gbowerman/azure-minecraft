#!/usr/bin/env python3
'''mcwebcheck.py
      - script to check the Java server version of Minecraft
      - designed to be run regularly to verify Minecraft server download version
      To do: Add exception handling
'''
import os
import requests


def main():
    # constants
    SERVER_URL = "https://minecraft.net/en-us/download/server/"
    MOJANG_URL = "https://api.mojang.com/users/profiles/minecraft/"

    # example minecraft user to test Mojang API
    MCUSER = "bugthing"

    # get the server download landing page
    download_page = requests.get(SERVER_URL).text

    # extract the server jar URL
    dl_idx = download_page.find('https://launcher')
    url_substr = download_page[dl_idx:]
    dl_end = url_substr.find('"')
    dl_url = url_substr[:dl_end]
    print(f"URL: {dl_url}")

    # check the URL exists
    response = requests.head(dl_url)
    print(f"Response: {response}")
    print(f"Size: {response.headers['Content-Length']}")

    # check Mojang API
    # convert Minecraft username to GUID using the Mojang API
    api_url = MOJANG_URL + MCUSER
    guid_dict = requests.get(api_url).json()
    guid_str = guid_dict['id']

    # convert to 8-4-4-4-12 format
    uuid_str = f"{guid_str[:8]}-{guid_str[8:12]}-{guid_str[12:16]}-{guid_str[16:20]}-{guid_str[20:32]}"
    print(f"UUID_str: {uuid_str}")


if __name__ == "__main__":
    main()