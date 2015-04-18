#!/usr/bin/bash

rpm -ivh http://yum.puppetlabs.com/el/6/products/i386/puppetlabs-release-6-7.noarch.rpm
yum install -y puppet-server puppet
chkconfig puppetmaster on
HN="`hostname`"
sed -i "s/#PUPPET_SERVER=puppet/PUPPET_SERVER='$HN'/; s/#PUPPET_LOG/PUPPET_LOG/" /etc/sysconfig/puppet
sed -i '14 c    dns_alt_names = puppet,'$HN /etc/puppet/puppet.conf
wget http://www.cs.duke.edu/~maxdml/experiments-setter/master-node.pp
wget http://www.cs.duke.edu/~maxdml/experiments-setter/spark-master.pp
wget http://www.cs.duke.edu/~maxdml/experiments-setter/guests-nodes.pp
puppet apply master-node.pp
puppet apply spark-master.pp
puppet apply guests-nodes.pp
