# azure-minecraft 
Azure templates to deploy minecraft servers

To use these templates you will need a current Microsoft Azure subscription, and your Minecraft user name.

## azuredeploy.json

This template will set up a customized Minecraft server with you as the operator. You can set common server properties as parameters at deployment time. Once the deployment is successful you can connect to the DNS address of the VM with a Minecraft launcher.

### Configurable parameters

Minecraft user name, difficulty, level-name, gamemode, white-list, enable-command-block, spawn-monsters, generate-structures, level-seed

You will also need to select an Azure location, a unique DNS name (e.g. "fredsminecraftsrvr"), an admin username and password for the virtual machine, and the name and location of an Azure Resource Group - this can be any name you choose.

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fgbowerman%2Fazure-minecraft%2Fmaster%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
