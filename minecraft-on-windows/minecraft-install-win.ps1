# Script to download and install Minecraft server on a clean Windows machine
# This script does the following:
#   - Install chocolatey
#   - Download and Install Minecraft client
#   - Install Java runtime
#   - Download Minecraft server JAR
#   - Start Minecraft server (future version will create a Windows service)

$minecraftVersion = "1.8.8"
$minecraftJar = "minecraft_server." + $minecraftVersion + ".jar"
$javaInstaller = "http://javadl.sun.com/webapps/download/AutoDL?BundleId=109717"
$clientExe = "MinecraftInstaller.msi"
$clientURL = "https://launcher.mojang.com/download/" + $clientExe
$webclient = New-Object System.Net.WebClient
$minecraftServerPath = $env:USERPROFILE + "\minecraft_server\"

# install chocolatey
(iex ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1')))>$null 2>&1

# download Minecraft client
$filePath = $env:USERPROFILE + "\Downloads\" + $clientExe
$webclient.DownloadFile($clientURL,$filePath)
# install Minecraft client 
msiexec /quiet /i $filePath

# install java 
choco install -y -force javaruntime

# reload PATH
$env:PATH = [System.Environment]::GetEnvironmentVariable("PATH","Machine")
$javaCommand = get-command java.exe
$javaPath = $javaCommand.Name
$jarPath = $minecraftServerPath + $minecraftJar

# download Minecraft server
md $minecraftServerPath
$url = "https://s3.amazonaws.com/Minecraft.Download/versions/" + $minecraftVersion + "/" + $minecraftJar
$webclient.DownloadFile($url,$jarPath)

# launch Minecraft server for first time
cd $minecraftServerPath

md logs
echo $null > server.properties
out-file -filepath .\banned-ips.json -encoding ascii -inputobject "[]`n"
out-file -filepath .\banned-players.json -encoding ascii -inputobject "[]`n"
out-file -filepath .\ops.json -encoding ascii -inputobject "[]`n"
out-file -filepath .\usercache.json -encoding ascii -inputobject "[]`n"
out-file -filepath .\whitelist.json -encoding ascii -inputobject "[]`n"

out-file -filepath .\eula.txt -encoding ascii -inputobject "eula=true`n"
iex "$javaPath -Xmx1024M -Xms1024M -jar $jarPath nogui"
