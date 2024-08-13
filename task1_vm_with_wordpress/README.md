# Notes

## Task

Create a virtual machine with Ubuntu Server 22.04. 
Deploy the latest WordPress on this virtual machine (without containerization). 
Write a script to back up the MySQL/MariaDB database and schedule it to run every weekday at 3 AM UTC. 
The backup name should include the date of its creation - backup_01.12.2023_12.53.sql. 
 Store the backup in the /opt/backups_wordpress directory.	

## My solution
`sh solution.sh`

### Prerequisites
Make sure you are logged into a valid account with `az account show`.
In case you cannot login with side auth provider (e.g. github) use `az login --use-device-code`.

### Description
In order to make the solution more interesting Microsoft Azure was selected as a cloud provider for compute resources. In order to gain relevant skills it was decided to use an [ARM Template](./template.json) to automate resource provisioning. Since it's not possible to create Resource Group via ARM Template, it is created via Azure CLI commands. Additionally, ARM Template includes configuring the newly created VM with a side script. It was decided to put it into a Storage Account service. Since this is not possible to do with ARM Templates, it's configured with Azure CLI as well.
ARM Template itself uses [external parametes file](./parameters.json) and does steps listed below:
- creates a Public Ip service
- creates Virtual Network
- creates NIC
- creates VM
- configures VM with Custom Script extension 

## Notes and Issues

### General
> 💡Add to ARM Template (✅ YES, this was done)
> 
> Can I add public ip creation and NSG configuration into ARM Template?

> 💡Remove JIT access
> 
> Can I restrict JIT access when I'm done?
> `az security vm jit-policy delete --resource-group $RESOURCE_GROUP --vm-name $VM_NAME`

> ⚠️ ARM Template cannot create Resource Groups
>
> For now ARM Template doesn't support creation of RG. It should be created separately.

> ⚠️ ARM Template cannot upload blobs to Storage Account
>
> For now ARM Template cannot upload files to storage account. They should be uploaded manually

### Order of Resource Creation
It's important to create RG before VM. Then I need to create VNet with subnets, NIC and only then VM. This fixes issue that VM cannot find NIC.

### SubscriptionNotRegistered error
Fixed like this:
https://www.dutchdatadude.com/fixing-subscription-is-not-registered-with-nrp-error-in-azure/

### Issue With Storage Account Container Creation
There was an issue stated {"created":false} with no explanation during creation of a Container inside an existing Storage Account. Fixed by adding ` --allow-blob-public-access`

