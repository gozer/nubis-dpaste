# Define how apache should be installed and configured.
# This uses the puppetlabs-apache puppet module [0].
#
# [0] https://github.com/puppetlabs/puppetlabs-apache
#

$vhost_name = 'dpaste'
$install_root = '/var/www/dpaste'
$wsgi_path = '/var/www/dpaste/wsgi.py'
$static_root = '/var/www/dpaste/dpaste/static/'
$port = 8080

include nubis_discovery

nubis::discovery { 'dpaste':
  tags => [ 'apache','backend' ],
  port => $port,
  check => "/usr/bin/curl -I http://localhost:$port",
  interval => "30s",
}

class {
    'apache':
        default_mods        => true,
        default_confd_files => false;
    'apache::mod::wsgi':
        wsgi_socket_prefix => '/var/run/wsgi';
}

apache::vhost { $::vhost_name:
    port                        => $port,
    default_vhost               => true,
    aliases                     => [
        # TODO, what do do about this? What if an app doesn't need this?
        {
         alias        => '/static',
         path         => $::static_root
        }
    ],
    docroot                     => $::install_root,
    wsgi_application_group      => '%{GLOBAL}',
    wsgi_daemon_process         => 'wsgi',
    wsgi_daemon_process_options => {
        processes    => '2',
        threads      => '15',
        display-name => '%{GROUP}',
    },
    wsgi_import_script          => $::wsgi_path,
    wsgi_import_script_options  => {
      'process-group'        => 'wsgi',
      'application-group'    => '%{GLOBAL}' },
    wsgi_process_group          => 'wsgi',
    wsgi_script_aliases         => { '/'    => $::wsgi_path },
}
