#!/bin/bash

# Updating the system
sudo dnf update && sudo dnf upgrade -y

# Install and configure DNS server
sudo dnf install -y bind bind-utils
# Configure /etc/named.conf and zone files

# Install DHCP server
sudo dnf install dhcp-server -y
# Configure /etc/dhcp/dhcpd.conf
sudo cd /etc/dhcp
printf 'option domain-name "easton-jackson.com";\nsubnet 10.0.5.1 netmask 255.255.255.0 {\nrange 10.0.5.1 10.0.5.254;\noption routers 10.0.5.1;\noption domain-name-servers 8.8.8.8, 8.8.4.4;\noption subnet-mask 255.255.255.0;\noption broadcast-address 192.168.1.255;\ndefault-lease-time 600;\nmax-lease-time 7200;\n}' | sudo tee dhcp.conf
sudo systemctl start dhcpd
sudo systemctl enable dhcpd

# Install openLDAP server
cd /home/eastonjackson1
sudo dnf install curl -y
sudo dnf install tar -y
sudo dnf install gcc -y
sudo dnf install sed -y
curl -O https://www.openldap.org/software/download/OpenLDAP/openldap-release/openldap-2.5.17.tgz
gunzip -c openldap-2.5.17.tgz | tar xvfB -
cd openldap-2.5.17
./configure
make depend
make
make test
su root -c 'make install'

# Configuring LDAP
cd /servers/slapd
sudo sed -i 's/olcSuffix: dc=my-domain,dc=com/olcSuffix: dc=easton-jackson,dc=com/g' slapd.ldif
sudo sed -i 's/cn=Manager,dc=my-domain/cn=Manager,dc=easton-jackson/g' slapd.ldif
sudo sed -i 's/olcRootPW: secret/olcRootPW: 1qaz!QAZ1qaz/g' slapd.ldif

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