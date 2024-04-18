#!/bin/bash

# Update system
sudo dnf update && sudo dnf upgrade -y

# Install required packages
sudo dnf install -y httpd mariadb mariadb-server php php-mysqlnd wget firewalld

# Start and enable services
sudo systemctl start httpd mariadb firewalld
sudo systemctl enable httpd mariadb firewalld

# Secure MariaDB installation
sudo mysql_secure_installation <<EOF

y
1qaz!QAZ1qaz
1qaz!QAZ1qaz
y
y
y
y
EOF

# Download and extract WordPress
wget https://wordpress.org/latest.tar.gz
tar -zxvf latest.tar.gz
sudo mv wordpress /var/www/html/
sudo chown -R apache:apache /var/www/html/wordpress
sudo chmod -R 755 /var/www/html/wordpress

# Create MariaDB database and user for WordPress
sudo mysql -u root -ppassword <<MYSQL_SCRIPT
CREATE DATABASE wordpress;
CREATE USER 'wordpressuser'@'localhost' IDENTIFIED BY 'password';
GRANT ALL PRIVILEGES ON wordpress.* TO 'wordpressuser'@'localhost';
FLUSH PRIVILEGES;
MYSQL_SCRIPT

# Configure WordPress
# Assuming the script will be run locally on the VM, open a web browser and go to http://localhost/wordpress to complete the installation.

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