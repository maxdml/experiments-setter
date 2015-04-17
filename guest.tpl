class guest-nodes {
    exec { 'wget':
        command => 'wget http://www.cs.duke.edu/~maxdml/$vdisk -P /mnt',
        path    => '/usr/bin'
    }

    virt { '$nodename':
        require   => Exec['wget'],
        memory    => $ram,
        cpus      => $cpus,
        virt_path => '/mnt/$vdisk',
        virt_type => 'kvm',
        ensure    => 'running'
    }
}

include virt
include guest-nodes
