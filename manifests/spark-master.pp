class setup-spark {
    exec { "wget":
        command => "wget http://d3kbcqa49mib13.cloudfront.net/spark-1.3.0.tgz",
        path    => "/usr/local/bin/:/bin/:/usr/bin/",
}   

    exec { "untar":
        command => "tar xzf spark-1.3.0.tgz -C /mnt",
        path    => "/bin/",
        require => Exec['wget']
    }

    exec { "install":
        command     => "mvn -Dhadoop.version=1.2.1 -DskipTests clean package",
        environment => "MAVEN_OPTS=$MAVEN_OPTS -Xmx2048m -XX:MaxPermSize=256m",
        timeout     => 0,
        cwd         => "/mnt/spark-1.3.0",
        path        => "/bin/:/usr/bin/",
        require     => Exec['untar']
    }

    file { '/mnt/spark-1.3.0/conf/spark-defaults.conf':
        ensure  => 'present',
        source  => '/mnt/spark-1.3.0/conf/spark-defaults.conf.template',
        require => Exec['install'] 
    }

    file { '/mnt/spark-1.3.0/conf/spark-env.sh':
        ensure  => 'present',
        source  => '/mnt/spark-1.3.0/conf/spark-env.sh.template',
        require => Exec['install'] 
    }

    exec { 'sparkconf':
        command => "echo 'spark.eventLog.dir /mnt/spark-1.3.0/logs'  >> /mnt/spark-1.3.0/conf/spark-defaults.conf && echo 'spark.eventLog.enabled true'  >> /mnt/spark-1.3.0/conf/spark-defaults.conf && echo 'spark.master spark://${::ipaddress}:7077'  >> /mnt/spark-1.3.0/conf/spark-defaults.conf",
        path    => "/bin/",
        require => [ File['/mnt/spark-1.3.0/conf/spark-defaults.conf'],
                     File['/mnt/spark-1.3.0/conf/spark-env.sh'] ]
    }

    exec { 'sparkenv':
        command => "echo SPARK_MASTER_IP=$::ipaddress >> /mnt/spark-1.3.0/conf/spark-env.sh",
        path    => "/bin/",
        require => File['/mnt/spark-1.3.0/conf/spark-env.sh']
    }
}

include setup-spark
