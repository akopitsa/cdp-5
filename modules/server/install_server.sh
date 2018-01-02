#!/bin/bash

dd if=/dev/zero of=/swapfile bs=1M count=2560
chown root:root  /swapfile
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile
echo "/swapfile   swap    swap    sw  0   0" >> /etc/fstab
echo "vm.swappiness = 100" >> /etc/sysctl.conf
echo "vm.vfs_cache_pressure = 50" >> /etc/sysctl.conf
sysctl -p
curl -O https://apt.puppetlabs.com/puppetlabs-release-pc1-xenial.deb
dpkg -i puppetlabs-release-pc1-xenial.deb
apt-get update
apt-get install -y ntp vim mc git ntpdate
apt-get -y install nginx
MYIP=`ifconfig | grep 'inet 10' | awk '{print $2}'` && echo 'This is: '$MYIP > /usr/share/nginx/html/index.html
systemctl start nginx.service
timedatectl set-timezone Europe/Kiev
ntpdate pool.ntp.org
sed -i 's/server 0.centos.pool.ntp.org/server 0.ua.pool.ntp.org/g' /etc/ntp.conf
sed -i 's/server 1.centos.pool.ntp.org/server 1.ua.pool.ntp.org/g' /etc/ntp.conf
sed -i 's/server 2.centos.pool.ntp.org/server 2.ua.pool.ntp.org/g' /etc/ntp.conf
sed -i 's/server 3.centos.pool.ntp.org/server 3.ua.pool.ntp.org/g' /etc/ntp.conf
systemctl restart ntpd
systemctl enable ntpd
apt-get install puppetserver -y
echo "autosign = true" >> /etc/puppetlabs/puppet/puppet.conf
#SERVERHOSTNAME=`/usr/bin/curl http://169.254.169.254/latest/meta-data/public-hostname` && \
echo "dns_alt_names = ${dns_name},server" >> /etc/puppetlabs/puppet/puppet.conf
sed -i -e 's/JAVA_ARGS="-Xms2g -Xmx2g -XX:MaxPermSize=256m"/JAVA_ARGS="-Xms512m -Xmx512m"/' "/etc/sysconfig/puppetserver"
#SERVERHOSTNAME=`/usr/bin/curl http://169.254.169.254/latest/meta-data/public-hostname` && \
echo "[main]" >> /etc/puppetlabs/puppet/puppet.conf && \
echo "certname =  ${dns_name}" >> /etc/puppetlabs/puppet/puppet.conf && \
echo "server =  ${dns_name}" >> /etc/puppetlabs/puppet/puppet.conf && \
echo "environment = production" >> /etc/puppetlabs/puppet/puppet.conf && \
echo "runinterval = 3m" >> /etc/puppetlabs/puppet/puppet.conf
echo """:backends:
  - yaml
  - eyaml
:hierarchy:
  - 'nodes/%{::trusted.certname}'
  - 'nodes/%{::fqdn}'
  - common
:yaml:
# datadir is empty here, so hiera uses its defaults:
# - /etc/puppetlabs/code/environments/%{environment}/hieradata on *nix
# When specifying a datadir, make sure the directory exists.
  :datadir: '/etc/puppetlabs/code/environments/%{::environment}/hieradata'
""" > /etc/puppetlabs/puppet/hiera.yaml
/opt/puppetlabs/puppet/bin/gem install r10k
/opt/puppetlabs/puppet/bin/gem install hiera-eyaml
/opt/puppetlabs/puppet/bin/eyaml createkeys
echo ''':cachedir: '/var/cache/r10k'
:sources:
  cdp:
    remote: 'https://github.com/akopitsa/control-repo.git'
    basedir: '/etc/puppetlabs/code/environments'
    prefix: false
''' >> /etc/puppetlabs/puppet/r10k.yaml
/opt/puppetlabs/puppet/bin/gem install hiera-eyaml
/opt/puppetlabs/bin/puppetserver gem install hiera-eyaml
/opt/puppetlabs/puppet/bin/r10k deploy environment production -pv -c /etc/puppetlabs/puppet/r10k.yaml
/opt/puppetlabs/puppet/bin/r10k deploy environment development -pv -c /etc/puppetlabs/puppet/r10k.yaml

free && sync && echo 3 > /proc/sys/vm/drop_caches && free
SERVERHOSTNAME=`/usr/bin/curl http://169.254.169.254/latest/meta-data/local-ipv4`
echo "$SERVERHOSTNAME       ${dns_name}" >> /etc/hosts
systemctl start puppetserver
systemctl enable puppetserver
