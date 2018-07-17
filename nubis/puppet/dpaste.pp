# Install mysql client libraries
include mysql::client

# With python bindings too
class { 'mysql::bindings':
    client_dev    => true,
}

# Install/manage python with PIP
class { 'python':
  version => 'system',
  pip     => true,
  dev     => true,
}

file { '/usr/var':
  ensure => directory,
}

# pip install requirements
python::requirements { "/var/www/${project_name}/requirements.txt":
  require => [
    Class['python'],
    Class['mysql::bindings'],
  ]
}

file { "/var/www/${project_name}/wsgi.py":
  ensure => present,
  source => 'puppet:///nubis/files/wsgi.py',
}

file { "/var/www/${project_name}/dpaste/settings/local.py":
  ensure => present,
  source => 'puppet:///nubis/files/local.py',
}

# Use Nubis's autoconfiguration hooks to trigger out config reloads

include nubis_configuration

file { "/usr/local/bin/${project_name}-update":
  ensure => present,
  source => 'puppet:///nubis/files/update',
  owner  => root,
  group  => root,
  mode   => '0755',
}

nubis::configuration{ $project_name:
  format => 'sh',
  reload => "/usr/local/bin/${project_name}-update"
}

include nubis_discovery

nubis::discovery::service { 'dpaste':
  tags     => [ 'dpaste' ],
  port     => '80',
  check    => '/usr/bin/curl -fis http://localhost:80',
  interval => '30s',
}
