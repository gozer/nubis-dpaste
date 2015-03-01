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
}

# XXX: Needs to move to its own puppet module
# XXX: needed for the migration instance
staging::file { 'envconsul.tar.gz':
  source => "https://github.com/hashicorp/envconsul/releases/download/v0.5.0/envconsul_0.5.0_linux_amd64.tar.gz"
} ->
staging::extract { 'envconsul.tar.gz':
  strip   => 1,
  target  => "/usr/local/bin",
  creates => "/usr/local/bin/envconsul",
} ->
file { "/usr/local/bin/envconsul":
  owner =>  0,
  group =>  0,
  mode  => '0555',
}
