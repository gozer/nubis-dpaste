class { 'python':
  version    => 'system',
  pip        => true,
  dev        => true,
}

python::requirements { '/var/www/dpaste/requirements.txt':
  require => Class['python']
}
