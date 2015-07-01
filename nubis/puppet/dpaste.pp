class { 'python':
  version    => 'system',
  pip        => true,
  dev        => true,
}

python::requirements { '/var/www/dpaste/requirements.txt':
  require => Class['python']
}

file { "/var/www/dpaste/wsgi.py":
  ensure => present,
  source => "puppet:///nubis/files/wsgi.py",
}

exec { "apt-get update":
    command => "/usr/bin/apt-get update",
}

package { 'makepasswd':
  ensure => '1.10-9',
  require  => Exec['apt-get update'],
}

package { 'apg':
  ensure => present,
  require  => Exec['apt-get update'],
}

file { '/usr/var':
  ensure => directory,
}

include nubis_configuration

nubis::configuration{ 'dpaste':
  format => "sh",
  reload => "apache2ctl graceful",
}
