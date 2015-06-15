exec { "wgets":
    command => "wget http://ftp.riken.jp/Linux/fedora/epel/RPM-GPG-KEY-EPEL-6 && wget http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm && wget http://repos.fedorapeople.org/repos/dchen/apache-maven/epel-apache-maven.repo -O /etc/yum.repos.d/epel-apache-maven.repo",
    path    => "/usr/local/bin/:/bin/:/usr/bin/",
}   
    
exec { "rpms":
    command => "rpm -ivh epel-release-6-8.noarch.rpm",
    path    => "/usr/local/bin/:/bin/:/usr/bin/",
    require => Exec['wgets']
}

$packages = ["java-1.8.0-openjdk", "apache-maven", "git", "qemu-kvm", "libvirt"]
package { $packages: 
    ensure  => "installed",
    require => [ Exec['wgets'], Exec['rpms'] ]
}

exec { 'kvm_intel_mod':
    command => "rmmod kvm_intel && modprobe kvm_intel",
    path    => "/sbin",
    require => Package[$packages]
}

exec { "puppet-virt":
    command => "git clone https://github.com/carlasouza/puppet-virt.git && mv puppet-virt /etc/puppet/modules/virt",
    path    => "/usr/local/bin/:/bin/:/usr/bin/",
    require => Package[$packages]
}   

exec { "conf-virt":
    command => "sed -i \"23 s/'qemu', //; s/kvm/qemu-kvm/; s/Fedora/CentOS/\" /etc/puppet/modules/virt/manifests/params.pp",
    path    => "/usr/local/bin/:/bin/:/usr/bin/",
    require => Exec['puppet-virt']
}

#maybe specific to Utah DDC nodes
exec { "mnt":
    command => "mkfs -t ext4 -F /dev/sda4",
    path    => "/sbin",
}

mount { "/mnt":
    require => Exec['mnt'],
    ensure  => 'mounted',
    atboot  => 'true',
    device  => '/dev/sda4',
    fstype  => 'ext4',
    options => 'defaults'
}

#related to an UID conflict in the base emulab CentOS image.
exec { 'fix-uid':
    command => "groupadd -g 307 fixgrp && usermod -u 307 -g 307 dhcpd",
    path    => "/usr/sbin",
}
