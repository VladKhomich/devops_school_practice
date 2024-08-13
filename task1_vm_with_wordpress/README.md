# Notes

## Task

Create a virtual machine with Ubuntu Server 22.04. 
Deploy the latest WordPress on this virtual machine (without containerization). 
Write a script to back up the MySQL/MariaDB database and schedule it to run every weekday at 3 AM UTC. 
The backup name should include the date of its creation - backup_01.12.2023_12.53.sql. 
 Store the backup in the /opt/backups_wordpress directory.	

## My solution

```
VM_NAME="myWordPressVM"
RESOURCE_GROUP="devopsschool1"
STORAGE_ACCOUNT="devopsschool1sa"
SA_CONTAINER="devopsschool1container"
LOCATION="polandcentral"
TEMPLATE_FILE="template.json"
PARAMETERS_FILE="parameters.json"
VM_SETUP_SCRIPT="install_wordpress.sh"
TAGS="Area=DevOpsSchool"

az group create --name $RESOURCE_GROUP --location $LOCATION --tags $TAGS
az storage account create --name $STORAGE_ACCOUNT --resource-group $RESOURCE_GROUP --location $LOCATION --sku Standard_LRS --allow-blob-public-access

az storage container create --name $SA_CONTAINER --account-name $STORAGE_ACCOUNT --public-access blob
az storage blob upload --account-name $STORAGE_ACCOUNT --container-name $SA_CONTAINER --name $VM_SETUP_SCRIPT --file $VM_SETUP_SCRIPT

az deployment group create --resource-group $RESOURCE_GROUP --template-file $TEMPLATE_FILE --parameters $PARAMETERS_FILE

az security vm jit-policy set \
  --resource-group $RESOURCE_GROUP \
  --vm-name $VM_NAME \
  --ports 22=22 \
  --max-request-access-duration PT1H

vm_ip=$(az vm show --resource-group $RESOURCE_GROUP --name $VM_NAME --show-details --query publicIps -o tsv)
ssh adminUser@$vm_ip

```

### Wordpress Script Template

Draft: use a file inside VM

1. nano install_wordpress.sh
2. chmod +x install_wordpress.sh
3. ./install_wordpress.sh

```
DB_NAME="wordpress"
DB_USER="wordpressuser"
DB_PASSWORD="YourStrongPassword"
DB_ROOT_PASSWORD="YourRootPassword"

sudo apt update && sudo apt upgrade -y

sudo apt install apache2 -y

sudo apt install mysql-server -y

sudo mysql -e "UPDATE mysql.user SET authentication_string=null WHERE User='root';"
sudo mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '$DB_ROOT_PASSWORD';"
sudo mysql -e "DELETE FROM mysql.user WHERE User='';"
sudo mysql -e "DELETE FROM mysql.user WHERE User='root' AND Host!='localhost';"
sudo mysql -e "DROP DATABASE IF EXISTS test;"
sudo mysql -e "FLUSH PRIVILEGES;"

sudo mysql -u root -p$DB_ROOT_PASSWORD -e "CREATE DATABASE $DB_NAME;"
sudo mysql -u root -p$DB_ROOT_PASSWORD -e "CREATE USER '$DB_USER'@'localhost' IDENTIFIED BY '$DB_PASSWORD';"
sudo mysql -u root -p$DB_ROOT_PASSWORD -e "GRANT ALL PRIVILEGES ON $DB_NAME.* TO '$DB_USER'@'localhost';"
sudo mysql -u root -p$DB_ROOT_PASSWORD -e "FLUSH PRIVILEGES;"

sudo apt install php php-mysql php-xml php-mbstring php-curl php-zip php-gd libapache2-mod-php -y

cd /tmp
wget https://wordpress.org/latest.tar.gz
tar -xvzf latest.tar.gz
sudo mv wordpress /var/www/html

sudo chown -R www-data:www-data /var/www/html/wordpress
sudo find /var/www/html/wordpress/ -type d -exec chmod 750 {} \;
sudo find /var/www/html/wordpress/ -type f -exec chmod 640 {} \;

sudo bash -c "cat > /etc/apache2/sites-available/wordpress.conf <<EOF
<VirtualHost *:80>
    ServerAdmin admin@your_domain_or_IP
    DocumentRoot /var/www/html/wordpress
    ServerName your_domain_or_IP

    <Directory /var/www/html/wordpress/>
        Options Indexes FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>

    ErrorLog \${APACHE_LOG_DIR}/error.log
    CustomLog \${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
EOF"

sudo a2ensite wordpress.conf
sudo a2enmod rewrite
sudo systemctl restart apache2

echo "WordPress has been installed. Please complete the installation by visiting site url in your web browser."

```




> 💡Add to ARM Template (✅ YES, this was done)
> 
> Can I add public ip creation and NSG configuration into ARM Template?

> 💡Remove JIT access
> 
> Can I restrict JIT access when I'm done?

> ⚠️ ARM Template cannot create Resource Groups
>
> For now ARM Template doesn't support creation of RG. It should be created separately.

> ⚠️ ARM Template cannot upload blobs to Storage Account
>
> For now ARM Template doesn't support creation of RG. It should be created separately.

## Notes and Issues

### Order of Resource Creation
It's important to create RG before VM. Then I need to create VNet with subnets, NIC and only then VM. This fixes issue that VM cannot find NIC.

### SubscriptionNotRegistered error
Fixed like this:
https://www.dutchdatadude.com/fixing-subscription-is-not-registered-with-nrp-error-in-azure/

