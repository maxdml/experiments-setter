class $guest-node {
    exec { 'create-$vdisk':
        command => 'qemu-img create -f qcow2 -b /mnt/spark_worker_base.qcow2 $vdisk.qcow2',
        path    => '/usr/bin',
        timeout => 0
    }

    virt { '$nodename':
        require   => Exec['create-$vdisk'],
        memory    => $ram,
        cpus      => $cpus,
        virt_path => '/mnt/$vdisk.qcow2',
        virt_type => 'kvm',
        ensure    => 'running'
    }
}

include virt
include $guest-node
