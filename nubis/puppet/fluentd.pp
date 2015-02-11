class { 'fluentd':
  service_ensure => stopped
}

fluentd::configfile { 'apache': }

fluentd::source { 'apache_access': 
  configfile => 'apache',
  type => 'tail',
  format => 'apache',
  tag => 'apache.access',
  config => {
    'path' => '/var/log/httpd/',
  },
}
