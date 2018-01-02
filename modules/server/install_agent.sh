#!/bin/bash

wget https://apt.puppetlabs.com/puppetlabs-release-pc1-xenial.deb
dpkg -i puppetlabs-release-pc1-xenial.deb
apt-get update
apt-get install -y ntpdate vim mc git 
timedatectl set-timezone Europe/Kiev
ntpdate pool.ntp.org
sed -i 's/server 0.centos.pool.ntp.org/server 0.ua.pool.ntp.org/g' /etc/ntp.conf
sed -i 's/server 1.centos.pool.ntp.org/server 1.ua.pool.ntp.org/g' /etc/ntp.conf
sed -i 's/server 2.centos.pool.ntp.org/server 2.ua.pool.ntp.org/g' /etc/ntp.conf
sed -i 's/server 3.centos.pool.ntp.org/server 3.ua.pool.ntp.org/g' /etc/ntp.conf
apt-get install -y puppet-agent
SERVERHOSTNAME=`/usr/bin/curl http://169.254.169.254/latest/meta-data/local-hostname`
echo """
[main]
certname = $SERVERHOSTNAME
server = ${dns_name}
environment = production
runinterval = 2m
""" >> /etc/puppetlabs/puppet/puppet.conf
systemctl start puppet
systemctl enable puppet
