DB_NAME="wordpress"
DB_USER="wordpressuser"
DB_PASSWORD="YourStrongPassword"
DB_ROOT_PASSWORD="YourRootPassword"
BACKUP_DIR="/opt/backups_wordpress"
SCRIPT_PATH="/opt/backup_mysql.sh"

echo "packages update"
sudo apt update && sudo apt upgrade -y

echo "install apache"
sudo apt install apache2 -y
echo "apache installed, now you can go to ip and check if it is running"

echo "install mysql"
sudo apt install mysql-server -y
echo "mysql installed"

echo "create db for wordpress"
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
echo "db created and configured"

echo "install php"
sudo apt install php php-mysql php-xml php-mbstring php-curl php-zip php-gd libapache2-mod-php -y
echo "php installed"

echo "install wordpress"
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

echo "wordpress was installed. navigate to site_url/wordpress to verify"

echo "create backup directory"
sudo mkdir -p $BACKUP_DIR
sudo chown -R $(whoami):$(whoami) $BACKUP_DIR

echo "create backup script"
cat <<EOL > $SCRIPT_PATH
#!/bin/bash
CURRENT_DATE=\$(date +"%d.%m.%Y_%H.%M")
BACKUP_FILE="backup_\${CURRENT_DATE}.sql"
mysqldump -u $DB_USER -p$DB_PASSWORD $DB_NAME > $BACKUP_DIR/\$BACKUP_FILE
echo "Backup \$BACKUP_FILE created successfully in $BACKUP_DIR."
EOL

echo "make backup script executable"
chmod +x $SCRIPT_PATH

echo "backup scheduling with cron"
(crontab -l 2>/dev/null; echo "0 3 * * 1-5 $SCRIPT_PATH") | crontab -

echo "backup script was created and sheduled to run"