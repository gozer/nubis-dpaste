class { 'python':
  version    => 'system',
  pip        => true,
  dev        => true,
}

python::requirements { '/var/www/dpaste/requirements.txt':
  require => Class['python']
}

package { 'apg':
  ensure => present,
}

include nubis_configuration

nubis::configuration{ 'dpaste':
  format => "sh",
  reload => "apache2ctl graceful",
}
