exec { "wgets":
    command => "wget http://ftp.riken.jp/Linux/fedora/epel/RPM-GPG-KEY-EPEL-6 && wget http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm && wget http://repos.fedorapeople.org/repos/dchen/apache-maven/epel-apache-maven.repo -O /etc/yum.repos.d/epel-apache-maven.repo && wget http://d3kbcqa49mib13.cloudfront.net/spark-1.3.0.tgz && wget http://d3kbcqa49mib13.cloudfront.net/spark-1.3.0.tgz",
    path    => "/usr/local/bin/:/bin/:/usr/bin/",
}   
    
exec { "rpms":
    command => "rpm -ivh epel-release-6-8.noarch.rpm",
    path    => "/usr/local/bin/:/bin/:/usr/bin/",
    require => Exec['wgets']
}

$packages = ["java-1.8.0-openjdk", "apache-maven", "git"]
package { $packages: 
    ensure => "installed"
}

exec { "puppet-virt":
    command => "git clone https://github.com/carlasouza/puppet-virt.git && mv puppet-virt /etc/puppet/modules/virt",
    path    => "/usr/local/bin/:/bin/:/usr/bin/",
    require => Package[$packages]
}   

exec { "conf-virt":
    command => "sed -i '18,21 s/^/#/' /etc/puppet/modules/virt/manifests/init.pp && sed -i '13 s/params:/params::servicename:/' /etc/puppet/modules/virt/manifests/init.pp && sed -i \"23 s/'qemu', //; s/kvm/qemu-kvm/; s/Fedora/CentOS/\" /etc/puppet/modules/virt/manifests/params.pp",
    path    => "/usr/local/bin/:/bin/:/usr/bin/",
    require => Exec:['puppet-virt']
}

exec { "mnt":
    command => "mkfs -t ext4 -F /dev/sda4",
    path    => "/sbin",
}

mount { "/mnt":
    require => Exec['mnt'],
    ensure  => 'mounted',
    atboot  => 'true',
    device  => '/root/disk',
    fstype  => 'ext4',
    options => 'default'
}
