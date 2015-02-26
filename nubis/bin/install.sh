#!/bin/bash
#
# TODO:
# All of the secrets stuff is just hacked in here right now this needs to be moved to Consul.
#+ The package installation stuff needs to move to puppet.
#+ Apache could use a cool script to interrigate Consul and we could get rid of the environment variables.
#+ The INSTALL_DIR is set in puppet and should be passed to this script or route through Consul.
#

#set -x

INSTALL_DIR="/var/www/dpaste"

echo "Executing install.sh"

sudo sh -c "echo \"PROVISION_app_db_server=localhost\\nPROVISION_db_name=dpaste\\nPROVISION_db_root_password=asillypassword\\nPROVISION_db_username=dpaste\\nPROVISION_db_password=anothersillypassword\\nPROVISION_app_secret_key=a-not-so-secret-key\" >> /etc/environment"

if [ `grep -c 'cat /etc/environment' /etc/apache2/envvars` != 1 ]; then
    sudo sh -c "echo '\\nfor i in \`cat /etc/environment | grep \"^PROVISION\"\`; do export \$i ; done' >> /etc/apache2/envvars"
fi

cd $INSTALL_DIR
for i in `cat /etc/environment | grep "^PROVISION"`; do export $i ; done
sudo -E python manage.py syncdb --migrate
