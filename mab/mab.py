'''mab.py - Minecraft Azure Bridge'''
import os
import sys
import time

from azure.common.credentials import ServicePrincipalCredentials
from azure.mgmt.compute import ComputeManagementClient
from dotenv import load_dotenv
from msrestazure.azure_exceptions import CloudError

# constants
LIST_VMS_FUNCTION_FILE = "/srv/minecraft_server/world/datapacks/mab/data/mab/functions/list_vms.mcfunction"

# relative coordinates to player standing on bridge
x_coord = 18
GROUND_HEIGHT = -2
y_coord = 7
X_LEN = 37
Y_LEN = 29
RUNNING_BLOCK = "minecraft:green_concrete"
DEALLOC_BLOCK = "minecraft:red_concrete"
TRANSIENT_BLOCK = "minecraft:gray_concrete"
DEFAULT_BLOCK = "minecraft:quartz_block"
DEFAULT_SIGN = "minecraft:birch_sign[rotation=8]"


def get_az_mgmt_client():
    '''Start an Azure management client connection '''
    subscription_id = os.environ["AZURE_SUBSCRIPTION_ID"]
    credentials = ServicePrincipalCredentials(
        client_id=os.environ["AZURE_CLIENT_ID"],
        secret=os.environ["AZURE_CLIENT_SECRET"],
        tenant=os.environ["AZURE_TENANT_ID"],
    )

    client = ComputeManagementClient(credentials, subscription_id)
    return client


def get_vm_list(client):
    '''list VMs in subscription'''
    vms = client.virtual_machines.list_all()
    return vms


def draw_sign(x_coord, height, y_coord, text1, text2, text3):
    '''create a string that draws a sign in a function file'''
    fill_line = f'setblock ~{x_coord} ~{height} ~{y_coord} {DEFAULT_SIGN}{{Text1:"\\"{text1}\\"",Text2:"\\"{text2}\\"",Text3:"\\"{text3}\\""}} destroy'
    return fill_line


def draw_vm(x_coord, height, y_coord, power_state):
    '''create a string that draws a VM in a function file'''

    block = DEFAULT_BLOCK
    fill_line = f"fill ~{x_coord} ~{height} ~{y_coord} ~{x_coord - 3} ~{height + 3} ~{y_coord} {block}\n"

    if  power_state == "VM running":
        block = RUNNING_BLOCK
    elif power_state == "VM deallocated":
        block = DEALLOC_BLOCK
    else:
        block = TRANSIENT_BLOCK

    fill_line += f"fill ~{x_coord - 1} ~{height + 1} ~{y_coord} ~{x_coord - 2} ~{height + 2} ~{y_coord} {block}"
    return fill_line


def get_rg_from_id_str(idstr):
    '''Identify the resource group from a VMr esource ID'''
    idx1 = idstr.index('Groups') + 7
    idx2 = idstr[idx1:].index('/')
    return idstr[idx1:idx1+idx2]


def write_to_file(filename, content_string):
    '''write the specified string to the specified file'''
    txt_file = open(filename, "w")
    txt_file.write(content_string)
    txt_file.close()


def write_vm_function(client, vm_list):
    '''write a Minecraft function to list VMs'''
    x = x_coord
    y = y_coord
    function_str = ""

    # loop through VM list
    for vm in vm_list:
        # print(vm)
        name = vm.name
        resource_group = get_rg_from_id_str(vm.id)
        power_state = client.virtual_machines.get(resource_group, name, expand='instanceView').instance_view.statuses[1].display_status
        # instance_view = client.virtual_machines.get(resource_group, name, expand='instanceView').instance_view
        #w_vm
        #print(instance_view)
        # get draw VM string
        draw_vm_str = draw_vm(x, GROUND_HEIGHT, y, power_state)
        # get draw sign string
        draw_sign_str = draw_sign(x, GROUND_HEIGHT, y - 1, f'{name}', f'{resource_group}', power_state)
        function_str += f'{draw_vm_str}\n{draw_sign_str}\n'
        # decrement x coordinate by 3
        x -= 5
    # write list VMs string to function file
    write_to_file(LIST_VMS_FUNCTION_FILE, function_str)
    #print(function_str)


def main():
    # load environment
    load_dotenv()

    print("Starting Minecraft Azure Bridge")
    # get an Azure client connection
    client = get_az_mgmt_client()

    while(True):
        # list the VMs in subscription
        vm_list = get_vm_list(client)
        write_vm_function(client, vm_list)
        time.sleep(10)


if __name__ == "__main__":
        main()
