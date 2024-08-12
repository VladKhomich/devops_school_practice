# Notes

## My solution
RESOURCE_GROUP="devopsschool1"
LOCATION="polandcentral"
TEMPLATE_FILE="template.json"
PARAMETERS_FILE="parameters.json"
TAGS="Area=DevOpsSchool"

az group create --name $RESOURCE_GROUP --location $LOCATION --tags $TAGS
az deployment group create --resource-group $RESOURCE_GROUP --template-file $TEMPLATE_FILE --parameters $PARAMETERS_FILE

Then it is required 
- create a public ip
- add NSG to allow any connection for 22 port (ssh service type) 
- enable JIT 
- connect via Azure Cloud Shell or via local bash: `ssh adminUser@<public-ip>`

> 💡Add to ARM Template
> 
> Can I add public ip creation and NSG configuration into ARM Template?

## Notes and Issues

### Order of Resource Creation
It's important to create RG before VM. Then I need to create VNet with subnets, NIC and only then VM. This fixes issue that VM cannot find NIC.

### SubscriptionNotRegistered error
Fixed like this:
https://www.dutchdatadude.com/fixing-subscription-is-not-registered-with-nrp-error-in-azure/

