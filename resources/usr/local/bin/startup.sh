#!/bin/bash

set -e

# cd to grav home
GRAV_HOME=/var/www/grav-admin
echo "[ INFO ]  Grav home set to " $GRAV_HOME
cd $GRAV_HOME

# Configure admin user
echo "[ INFO ]  Setting up grav admin user"
bin/plugin login newuser --user=$ADMIN_USER \
                         --password=$ADMIN_PASSWORD \
                         --email=$ADMIN_EMAIL \
                         --permissions=$ADMIN_PERMISSIONS \
                         --fullname=$ADMIN_FULLNAME \
                         --title=$ADMIN_TITLE

# Set the correct permissions
echo "[ INFO ]  Setting folder permissions on grav home"
chown -R www-data:www-data $GRAV_HOME

# Set the domain name in the nginx config
echo "[ INFO ]  Setting server_name to " ${DOMAIN}
sed -i 's/server_name localhost/server_name '${DOMAIN}'/g' /etc/nginx/conf.d/default.conf

# Run nginx as foreground process
echo "[ INFO ]  Starting nginx"
bash -c 'php5-fpm -D; nginx -g "daemon off;"'