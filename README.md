# azure-minecraft
A collection of scripts for deploying and upgrading Minecraft and related servers

Check the last check-in dates - parts of repo are not maintained and are not up to date. 

The [azure-marketplace](./azure-marketplace) folder contains the source files for the [Azure Marketplace Minecraft Solution template](https://azuremarketplace.microsoft.com/en-us/marketplace/apps/msftstack.minecraft-server?tab=Overview).

The scripts folder contains:
- A script to get the Minecraft UUID
- A script to upgrade your Azure minecraft server to a new version.

Note: If you're customizing the vanilla Minecraft server and using Forge/Spigot, you'll need to use the Oracle JDK instead of the OpenJDK. See: https://www.itzgeek.com/how-tos/linux/ubuntu-how-tos/install-java-jdk-8-on-ubuntu-14-10-linux-mint-17-1.html - Thanks to @matthewfcarlson for pointing this out.
