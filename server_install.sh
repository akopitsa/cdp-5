#!/bin/bash

sudo dd if=/dev/zero of=/swapfile bs=1M count=5120
sudo chown root:root  /swapfile
sudo chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile
sudo echo "/swapfile   swap    swap    sw  0   0" >> /etc/fstab
sudo echo "vm.swappiness = 100" >> /etc/sysctl.conf
sudo echo "vm.vfs_cache_pressure = 50" >> /etc/sysctl.conf
sudo sysctl -p
sudo yum update
sudo yum install -y ntp vim mc git tree net-tools
sudo timedatectl set-timezone Europe/Kiev
sudo ntpdate pool.ntp.org
sudo sed -i 's/server 0.centos.pool.ntp.org/server 0.ua.pool.ntp.org/g' /etc/ntp.conf
sudo sed -i 's/server 1.centos.pool.ntp.org/server 1.ua.pool.ntp.org/g' /etc/ntp.conf
sudo sed -i 's/server 2.centos.pool.ntp.org/server 2.ua.pool.ntp.org/g' /etc/ntp.conf
sudo sed -i 's/server 3.centos.pool.ntp.org/server 3.ua.pool.ntp.org/g' /etc/ntp.conf
sudo systemctl restart ntpd
sudo systemctl enable ntpd
sudo rpm -ivh https://yum.puppetlabs.com/puppetlabs-release-pc1-el-7.noarch.rpm
sudo yum -y install puppetserver
