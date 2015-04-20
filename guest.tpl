class $guest-node {
    exec { 'wget-$vdisk':
        command => 'wget http://www.cs.duke.edu/~maxdml/$vdisk -P /mnt',
        path    => '/usr/bin',
        timeout => 0
    }

    virt { '$nodename':
        require   => Exec['wget-$vdisk'],
        memory    => $ram,
        cpus      => $cpus,
        virt_path => '/mnt/$vdisk',
        virt_type => 'kvm',
        ensure    => 'running'
    }
}

include virt
include $guest-node
