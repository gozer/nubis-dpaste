# Main entry for puppet
#
# import is deprecated and we should use another
# method for including these manifests
#

import 'dpaste.pp'
import 'apache.pp'
import 'mysql.pp'
import 'fluentd.pp'

exec { "apt-get update":
    command => "/usr/bin/apt-get update",
}

package { 'makepasswd':
  ensure => '1.10-9',
  require  => Exec['apt-get update'],
}
