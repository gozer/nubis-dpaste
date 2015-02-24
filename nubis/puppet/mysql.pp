$root_password = 'asillypassword'
$db_name = 'dpaste'
$username = 'dpaste'
$password = 'anothersillypassword'
$allowed_hosts = 'localhost'

class { '::mysql::server':
    root_password    => $::root_password,
    restart          => true,
    override_options => {
        'mysqld' => {
            'bind-address' => '0.0.0.0',
        }
    }
}

::mysql::db { $::db_name:
    user     => $::username,
    password => $::password,
    host     => $::host,
    # TODO, figure out how to pass this as a param.
    # Unicode formating is breaking things.
    # The list looks like [u'SELECT', u'UPDATE', ...]
    # and puppet doesn't like that.
    grant    => ['ALL']
}

include mysql::client
class { 'mysql::bindings':
    python_enable => true
}
