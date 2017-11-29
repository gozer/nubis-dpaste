# Define how apache should be installed and configured.
# This uses the puppetlabs-apache puppet module [0].
#
# [0] https://github.com/puppetlabs/puppetlabs-apache
#

$vhost_name = $project_name
$install_root = "/var/www/${project_name}"
$wsgi_path = "/var/www/${project_name}/wsgi.py"
$static_root = "/var/www/${project_name}/dpaste/static/"
$port = 80

class { 'nubis_apache':
}

class { 'apache::mod::wsgi':
    wsgi_socket_prefix => '/var/run/wsgi';
}

apache::vhost { $::vhost_name:
    port                        => $port,
    default_vhost               => true,
    docroot                     => $::install_root,
    docroot_owner               => 'nubis',
    docroot_group               => 'nubis',
    block                       => ['scm'],
    setenvif                    => [
      'X_FORWARDED_PROTO https HTTPS=on',
      'Remote_Addr 127\.0\.0\.1 internal',
      'Remote_Addr ^10\. internal',
    ],
    access_log_env_var          => '!internal',
    access_log_format           => '%a %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-agent}i\"',
    headers                     => [
      "set X-Nubis-Version ${project_version}",
      "set X-Nubis-Project ${project_name}",
      "set X-Nubis-Build   ${packer_build_name}",
    ],
    aliases                     => [
        {
            alias => '/static',
            path  => $::static_root
        }
    ],
    wsgi_application_group      => '%{GLOBAL}',
    wsgi_daemon_process         => 'wsgi',
    wsgi_daemon_process_options => {
        processes    => '2',
        threads      => '15',
        display-name => '%{GROUP}',
    },
    wsgi_import_script          => $::wsgi_path,
    wsgi_import_script_options  => {
      process-group     => 'wsgi',
      application-group => '%{GLOBAL}'
    },
    wsgi_process_group          => 'wsgi',
    wsgi_script_aliases         => { '/' => $::wsgi_path },
}

