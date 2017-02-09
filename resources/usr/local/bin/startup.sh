#!/bin/bash

set -e

# Go to grav home
export GRAV_HOME=/var/www/grav-admin
echo "[ INFO ] Grav home set to" $GRAV_HOME
cd $GRAV_HOME

# Set the correct permissions
echo "[ INFO ] Setting folder permissions on grav home"
chown -R www-data:www-data $GRAV_HOME

if [ -e $GRAV_HOME/grav-configured ]; then
	echo "[ INFO ] Grav already configured"
else

    if [ -z $ADMIN_USER ]; then
        echo "[ INFO ] No Grav admin user details supplied"
    else
        if [ -e $GRAV_HOME/user/accounts/$ADMIN_USER.yaml ]; then
            echo "[ INFO ] Grav admin user already exists"
        else
            echo "[ INFO ] Setting up Grav admin user"

            bin/plugin login newuser --user=${ADMIN_USER} \
                                     --password=${ADMIN_PASSWORD-"Pa55word"} \
                                     --permissions=${ADMIN_PERMISSIONS-"b"} \
                                     --email=${ADMIN_EMAIL-"admin@domain.com"} \
                                     --fullname=${ADMIN_FULLNAME-"Administrator"} \
                                     --title=${ADMIN_TITLE-"SiteAdministrator"}

            chown www-data:www-data $GRAV_HOME/user/accounts/$ADMIN_USER.yaml
        fi
    fi

    # Set the domain name in the nginx config
    if [ -z $DOMAIN ]; then
        echo "[ INFO ] No Domain supplied. Defaulting to localhost"
    else
        echo "[ INFO ] Setting server_name to " ${DOMAIN}
        sed -i 's/server_name localhost/server_name '${DOMAIN}'/g' /etc/nginx/conf.d/default.conf
    fi

    # Touch file to indicate we're configured for future startups
    touch /var/www/grav-admin/grav-configured
fi

# Run nginx as foreground process
echo "[ INFO ] Starting nginx"
bash -c 'php5-fpm -D; nginx -g "daemon off;"'