# Main entry for puppet
#
# import is deprecated and we should use another
# method for including these manifests
#

import 'apache.pp'
import 'mysql.pp'
import 'fluentd.pp'
