# Install Scriptcraft server on an Ubuntu Virtual Machine using the Linux Custom Script Extension

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fgbowerman%2Fazure-minecraft%2Fmaster%2Fscriptcraft-on-ubuntu%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>

This template deploys and sets up a customized Scriptcraft server on an Ubuntu Virtual Machine, with you as the operator. It also deploys an Azure Storage Account, Virtual Network, Public IP addresses and a Network Interface.

You can set common Minecraft server properties as parameters at deployment time. Once the deployment is successful you can connect to the DNS address of the VM with a Minecraft launcher. 

See <a href="https://msftstack.wordpress.com/2015/10/27/azure-templates-for-computercraftedu-and-scriptcraft-servers/">Azure templates for ComputerCraftEdu and ScriptCraft servers</a> for more details.

The following server configuration parameters can be set at deployment time: Minecraft user name.

