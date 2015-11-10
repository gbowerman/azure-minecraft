# Install Minecraft server 1.7.10 on an Ubuntu Virtual Machine using the Linux Custom Script Extension

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fgbowerman%2Fazure-minecraft%2Fmaster%2Fminecraft1.7.10-on-ubuntu%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>


This template deploys and sets up a customized Minecraft 1.7.10 server on an Ubuntu Virtual Machine, with you as the operator. It also deploys a Storage Account, Virtual Network, Public IP addresses and a Network Interface.

You can set common Minecraft server properties as parameters at deployment time. Once the deployment is successful you can connect to the DNS address of the VM with a Minecraft or Minecraft EDU launcher. 

The following Minecraft server configuration parameters can be set at deployment time: Minecraft user name, difficulty, level-name, gamemode, white-list, enable-command-block, spawn-monsters, generate-structures, level-seed.

For more information on how to use this template, refer to this blog (which was written for the Minecraft server 1.8 version of this template) <a href="https://msftstack.wordpress.com/2015/09/05/creating-a-minecraft-server-using-an-azure-resource-manager-template/">Creating a Minecraft server using an Azure Resource Manager template</a>.
