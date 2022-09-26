#!/bin/bash

# unmount /dev/sda4
sudo umount /mydata
cat /etc/fstab | grep -v '^#' | grep -v '/mydata' | sudo tee /etc/fstab
# remove lvm
sudo lvremove -y $(sudo lvdisplay | grep /dev/emulab/node*-bs -o)
sudo vgremove /dev/emulab
# delete partition 4 and create two new partitions
echo "d
4
n
e


n

+60G
n


w
" | sudo fdisk /dev/sda
sudo reboot
