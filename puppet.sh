#!/usr/bin/bash

rpm -ivh http://yum.puppetlabs.com/el/6/products/i386/puppetlabs-release-6-7.noarch.rpm &>> /local/init.log 
yum install -y puppet-server puppet &>> /local/init.log
chkconfig puppetmaster on &>> /local/init.log
HN="`hostname`" &>> /local/init.log
sed -i "s/#PUPPET_SERVER=puppet/PUPPET_SERVER='$HN'/; s/#PUPPET_LOG/PUPPET_LOG/" /etc/sysconfig/puppet &>> /local/init.log
sed -i '14 c    dns_alt_names = puppet,'$HN /etc/puppet/puppet.conf &>> /local/init.log 
wget http://www.cs.duke.edu/~maxdml/experiments-setter/spark-master.pp &>> /local/init.log
puppet apply spark-master.pp  &>> /local/init.log
