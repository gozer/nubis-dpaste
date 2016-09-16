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

file { "/var/www/dpaste/dpaste/settings/local.py": 
  ensure => present,
  source => "puppet:///nubis/files/local.py",
}

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
