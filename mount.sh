#!/bin/bash

# sudo tar -zcvf /home.tar.gz $HOME

sudo wipefs -a /dev/sda4
sudo wipefs -a /dev/sda5
sudo wipefs -a /dev/sda6

sudo mkfs.ext3 /dev/sda5

mkdir -p $HOME/data
sudo mount /dev/sda5 $HOME/data
sudo chown -R $(id -u):$(id -g) $HOME/data
echo "/dev/sda5 $HOME/data ext3 defaults 0 0" | sudo tee -a /etc/fstab

# sudo tar -xvf /home.tar.gz && sudo rm /home.tar.gz
