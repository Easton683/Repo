#!/bin/bash

# Updating the system
sudo dnf update && sudo dnf upgrade -y

# Install and configure DNS server
sudo dnf install -y bind bind-utils
# Configure /etc/named.conf and zone files

# Install and configure DHCP server
sudo dnf install -y dhcp
# Configure /etc/dhcp/dhcpd.conf

# Install and configure LDAP server
sudo dnf install curl -y
sudo dnf install tar -y
sudo dnf install gcc -y
curl -O https://www.openldap.org/software/download/OpenLDAP/openldap-release/openldap-2.5.17.tgz
gunzip -c openldap-2.5.17.tgz | tar xvfB -
cd openldap-2.5.17
./configure
make depend
make
make test
su root -c 'make install'

# Install and configure firewalld
sudo dnf install -y firewalld
sudo systemctl enable firewalld
sudo systemctl start firewalld
sudo firewall-cmd --zone=public --add-service=dns --permanent
sudo firewall-cmd --zone=public --add-service=dhcp --permanent
sudo firewall-cmd --zone=public --add-service=ldap --permanent
sudo firewall-cmd --reload

# Configure auto updates
sudo dnf install -y dnf-automatic
sudo systemctl enable --now dnf-automatic.timer