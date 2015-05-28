# Main entry for puppet
#
# import is deprecated and we should use another
# method for including these manifests
#

import 'dpaste.pp'
import 'apache.pp'
import 'mysql.pp'
import 'fluentd.pp'
