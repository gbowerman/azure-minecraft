#!/bin/bash
# Script to convert a Minecraft username to a UUID that you can use in operator/whitelist files etc.
# $1 = Minecraft user name

if [[ ! $# -eq 1 ]] ; then
    echo 'Error: Expected one argument: Minecraft user name.'
    exit 1
fi

UUID_URL=https://api.mojang.com/users/profiles/minecraft/$1
mojang_output="`wget -qO- $UUID_URL`"
rawUUID=${mojang_output:7:32}
UUID=${rawUUID:0:8}-${rawUUID:8:4}-${rawUUID:12:4}-${rawUUID:16:4}-${rawUUID:20:12}
echo $UUID

