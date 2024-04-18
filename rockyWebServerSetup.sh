#!/bin/bash

# Update system
sudo dnf update && sudo dnf upgrade -y

# Install required packages 
dnf install -y httpd mariadb-server php php-mysqlnd 
 
# Start and enable Apache 
systemctl start httpd 
systemctl enable httpd 
 
# Start and enable MariaDB 
systemctl start mariadb 
systemctl enable mariadb 
 
# Secure MariaDB installation 
mysql_secure_installation 
 
# Create a new database for WordPress 
mysql -u root -p -e "CREATE DATABASE wordpress;" 
mysql -u root -p -e "GRANT ALL PRIVILEGES ON wordpress.* TO 'wordpress'@'localhost' IDENTIFIED BY 'password';" 
mysql -u root -p -e "FLUSH PRIVILEGES;" 
 
# Download and extract WordPress 
wget https://wordpress.org/latest.tar.gz 
tar -xzf latest.tar.gz -C /var/www/html/ 
 
# Set permissions 
chown -R apache:apache /var/www/html/wordpress 
chmod -R 755 /var/www/html/wordpress 
 
# Configure Apache 
cp /var/www/html/wordpress/wp-config-sample.php /var/www/html/wordpress/wp-config.php 
sed -i 's/database_name_here/wordpress/g' /var/www/html/wordpress/wp-config.php 
sed -i 's/username_here/wordpress/g' /var/www/html/wordpress/wp-config.php 
sed -i 's/password_here/password/g' /var/www/html/wordpress/wp-config.php 
 
# Restart Apache 
systemctl restart httpd 
 
# WORDRESS USER PASSWORD 
#  )&tHIoshN!XA8f*17y

# Open HTTP and HTTPS ports in firewall
sudo firewall-cmd --permanent --add-service=http
sudo firewall-cmd --permanent --add-service=https
sudo firewall-cmd --reload

# Configure automatic updates
sudo sed -i 's/apply_updates = no/apply_updates = yes/' /etc/dnf/automatic.conf
sudo sed -i 's/upgrade_type = default/upgrade_type = security/' /etc/dnf/automatic.conf
sudo sed -i 's/upgrade_day =/upgrade_day = wed/' /etc/dnf/automatic.conf
sudo sed -i 's/upgrade_time =/upgrade_time = 23:30/' /etc/dnf/automatic.conf

# Enable and start the dnf-automatic timer
sudo systemctl enable --now dnf-automatic.timer