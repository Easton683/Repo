#!/bin/bash

# Updating the system
sudo apt update && sudo apt upgrade -y

# Downloading image to home and setting it as the background
sudo apt install curl -y
curl -o background.jpg "https://cdn1.vectorstock.com/i/1000x1000/57/05/sysadmin-computer-and-technical-support-cartoon-vector-19575705.jpg"
gsettings set org.gnome.desktop.background picture-uri "$(pwd)/background.jpg"

# Installing Plymouth Theme
sudo apt install plymouth-themes -y
yes 2 | sudo update-alternatives --config default.plymouth

# installing powerline and configuring for BASH and Vim
sudo apt install powerline -y
echo "source /usr/share/powerline/bindings/bash/powerline.sh" >> ~/.bashrc
echo "set rtp+=/usr/share/powerline/bindings/vim/" >> ~/.vimrc

# Install and configure firewalld
sudo apt install -y firewalld
sudo systemctl enable firewalld
sudo systemctl start firewalld
sudo firewall-cmd --zone=public --add-service=ssh --permanent
sudo firewall-cmd --reload

# Write the cron job to a temporary file and then inputting it into cron
echo "30 23 * * 4 root apt update && apt upgrade -y" > /tmp/auto_updates_cron
sudo crontab /tmp/auto_updates_cron
rm /tmp/auto_updates_cron