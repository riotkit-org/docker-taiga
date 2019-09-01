#!/bin/bash

correct_permissions () {
    echo " >> Setting user id and group id"
    usermod -u "$DJANGO_USER_ID" django
    groupmod -g "$DJANGO_GROUP_ID" django

    echo " >> Correcting permissions"
    chown taiga:taiga /usr/src /var/log/nginx/ /var/run/nginx.pid /var/lib/nginx /usr/src/taiga-back/media -R
}

prepare_configs() {
    echo " >> Preparing configuration files..."
    echo " HINT: Add your files into /etc/nginx/extensions.d to include them in NGINX configuration"
    j2 /opt/taiga-conf/nginx/nginx.conf.j2 >  /etc/nginx/nginx.conf
    j2 /opt/taiga-conf/taiga/conf.json.j2 > /usr/src/taiga-front-dist/dist/conf.json
}

migrate() {
    echo " >> Preparing a database migration"

    : ${TAIGA_DB_CONNECT_TIMEOUT:=120}
    DB_AVAILABLE=false
    DB_TEST_START=$(date +%s)

    # Setup database automatically if needed
      while [ "$DB_AVAILABLE" = "false" ]; do
        echo "Running database check"
        python /checkdb.py
        DB_CHECK_STATUS=$?

        if [ $DB_CHECK_STATUS -eq 1 ]; then
            DB_FAILED_TIME=$(date +%s)
            if [[ $(($DB_FAILED_TIME-$DB_TEST_START)) -gt $TAIGA_DB_CONNECT_TIMEOUT ]]; then
               echo "Failed to connect to database for more than TAIGA_DB_CONNECT_TIMEOUT seconds. Exiting..."
               exit 1
            fi

            echo "Failed to connect to database server or database does not exist."
            sleep 10

        elif [ $DB_CHECK_STATUS -eq 2 ]; then
            DB_AVAILABLE=true
            echo "Configuring initial database"
            python manage.py migrate --noinput
            python manage.py loaddata initial_user
            python manage.py loaddata initial_project_templates
            python manage.py loaddata initial_role
            python manage.py compilemessages
        else
            DB_AVAILABLE="true"
        fi
      done

    # Look for static folder, if it does not exist, then generate it
    if [ ! -d "/usr/src/taiga-back/static" ]; then
        python manage.py collectstatic --noinput
    fi
}

correct_permissions
prepare_configs
migrate

set -x
nginx -t
chown taiga:taiga /usr/src/taiga-back/media

# Start Taiga backend Django server
exec "$@"
