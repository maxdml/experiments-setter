class setup-spark {
    exec {"get-worker-image":
        command => "wget http://www.cs.duke.edu/~maxdml/spark_worker_base.qcow2 -P /mnt"
        path    => "/usr/local/bin/:/bin/:/usr/bin/",
    }

    exec { "git-spark":
        command => "git clone https://github.com/apache/spark.git /mnt/spark"
        path    => "/usr/local/bin/:/bin/:/usr/bin/",
    }

    exec { "install":
        command     => "build/sbt clean assembly"
        timeout     => 0,
        cwd         => "/mnt/spark/",
        path        => "/bin/:/usr/bin/",
        require     => Exec['git-spark']
    }

    file { '/mnt/spark/conf/spark-defaults.conf':
        ensure  => 'present',
        source  => '/mnt/spark/conf/spark-defaults.conf.template',
        require => Exec['install']
    }

    file { '/mnt/spark/conf/spark-env.sh':
        ensure  => 'present',
        source  => '/mnt/spark/conf/spark-env.sh.template',
        require => Exec['install']
    }

    exec { 'sparkconf':
        command => "echo 'spark.eventLog.dir /mnt/spark/logs'  >> /mnt/spark/conf/spark-defaults.conf && echo 'spark.eventLog.enabled true'  >> /mnt/spark/conf/spark-defaults.conf && echo 'spark.master spark://${::ipaddress}:7077'  >> /mnt/spark/conf/spark-defaults.conf",
        path    => "/bin/",
        require => [ File['/mnt/spark/conf/spark-defaults.conf'],
                     File['/mnt/spark/conf/spark-env.sh'] ]
    }

    exec { 'sparkenv':
        command => "echo SPARK_MASTER_IP=$::ipaddress >> /mnt/spark/conf/spark-env.sh",
        path    => "/bin/",
        require => File['/mnt/spark/conf/spark-env.sh']
    }
}

include setup-spark
