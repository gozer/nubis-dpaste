# Install mysql client libraries
include mysql::client

# With python bindings too
class { 'mysql::bindings':
    python_enable => true
}

# Install/manage python with PIP
class { 'python':
  version    => 'system',
  pip        => true,
  dev        => true,
}

file { "/usr/var":
  ensure => directory,
}

# pip install requirements
python::requirements { '/var/www/dpaste/requirements.txt':
  require => [
    Class['python'],
    Class['mysql::bindings'],
  ]
}

file { "/var/www/dpaste/wsgi.py":
  ensure => present,
  source => "puppet:///nubis/files/wsgi.py",
}

file { "/var/www/dpaste/dpaste/settings/local.py": 
  ensure => present,
  source => "puppet:///nubis/files/local.py",
}

# Use Nubis's autoconfiguration hooks to trigger out config reloads

include nubis_configuration

file { "/usr/local/bin/dpaste-update":
  ensure => present,
  source => "puppet:///nubis/files/update",
  owner  => root,
  group  => root,
  mode   => '0755',
}

nubis::configuration{ 'dpaste':
  format => "sh",
  reload => "/usr/local/bin/dpaste-update"
}

