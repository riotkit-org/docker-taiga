FROM python:3.7-slim
MAINTAINER Benjamin Hutchins <ben@hutchins.co>
MAINTAINER Riotkit <riotkit_org@riseup.net>

# build-time arguments, use them in docker build with --build-arg switch to build different version
ARG RKT_APP_VERSION=UNKNOWN
ARG FRONTEND_VERSION=UNKNOWN

# runtime arguments
ENV DEBIAN_FRONTEND=noninteractive \
    # Set to "c" for English, pl-PL.UTF-8 for Polish etc.
    LANG=en_US.UTF-8 \
    # Timezone
    TZ="Europe/Warsaw" \
    # Set to "c" for English, pl-PL.UTF-8 for Polish etc.
    LC_TYPE=en_US.UTF-8 \
    # Enable mail server
    TAIGA_ENABLE_EMAIL=False \
    # Use TLS encryption when sending mails
    TAIGA_EMAIL_USE_TLS=true\
    # SMTP server host
    TAIGA_EMAIL_HOST=smtp \
    # SMTP server port
    TAIGA_EMAIL_PORT=25 \
    # SMTP user login
    TAIGA_EMAIL_USER=taiga@riotkit.org \
    # SMTP user password
    TAIGA_EMAIL_PASS=some-password \
    # SMTP "From" header value
    TAIGA_EMAIL_FROM=taiga@localhost \
    # Queue connection string
    TAIGA_BROKER_URL=amqp://guest:guest@rabbit:5672 \
    # Redis url
    TAIGA_REDIS_URL="redis://redis:6379/0" \
    # Enables Celery support
    CELERY_ENABLED=false \
    # Serializer type supported by Taiga at Celery
    CELERY_SERIALIZER_TYPE=pickle \
    # Default locale ex. en, pl
    TAIGA_DEFAULT_LOCALE=en \
    # !!! Secret key, please change it with your own
    TAIGA_SECRET_KEY=REPLACE-ME-j1598u1J^U*(y251u98u51u5981urf98u2o5uvoiiuzhlit3) \
    # PostgreSQL database name
    TAIGA_DB_NAME=taiga \
    # PostgreSQL database hostname
    TAIGA_DB_HOST=postgres \
    # PostgreSQL database user login
    TAIGA_DB_USER=taiga \
    # PostgreSQL database user password
    TAIGA_DB_PASSWORD= \
    # Protocol http or https your instance will listen on
    TAIGA_SCHEME=http \
    # Enable or disable events?
    TAIGA_ENABLE_EVENTS=false \
    # Hostname for events server
    TAIGA_EVENTS_HOST=events \
    # Hostname of your instance (domain ex. riotkit.org or subdomain - board.riotkit.org)
    TAIGA_HOSTNAME=localhost \
    # Set to `true` to enable the LDAP authentication.
    TAIGA_LDAP=false \
    # The LDAP server URL.
    LDAP_SERVER="" \
    # The port to connect to the LDAP server on.
    LDAP_PORT=0 \
    # Set to `true` to enable StartTLS when connecting to the server.
    LDAP_START_TLS="false" \
    # The DN to bind to the LDAP server with. If left blank the client will attempt to bind anonymously.
    LDAP_BIND_DN="" \
    # The password for the bind DN.
    LDAP_BIND_PASSWORD="" \
    # The root of the LDAP structure in which to search for user accounts.
    LDAP_SEARCH_BASE="" \
    # Additional filter added to the user account query.
    LDAP_SEARCH_FILTER_ADDITIONAL="" \
    # The LDAP attribute that will be used for the account's Taiga username.
    LDAP_USERNAME_ATTRIBUTE="uid" \
    # The LDAP attribute that will be used for the account's Email address.
    LDAP_EMAIL_ATTRIBUTE="mail" \
    # The LDAP attribute that will be used for the account's full name.
    LDAP_FULL_NAME_ATTRIBUTE="cn" \
    # The fallback authentication method to use if LDAP fails. This will allows users to login with either an LDAP account or a local account. Set to a blank string to prevent logging in with anything other than LDAP.
    LDAP_FALLBACK="normal" \
    # Whether or not to save the LDAP password in the local database. If `LDAP_FALLBACK` is set to `normal` this will allow users that have logged in with LDAP before to login even if the LDAP server is unavailable.
    LDAP_SAVE_LOGIN_PASSWORD="true" \
    # Enable the GitHub project importer
    TAIGA_IMPORTER_GITHUB_ENABLED="false" \
    # GitHub importer client ID
    TAIGA_IMPORTER_GITHUB_CLIENT_ID="" \
    # GitHub importer client secret
    TAIGA_IMPORTER_GITHUB_CLIENT_SECRET="" \
    # Enable the Trello project importer
    TAIGA_IMPORTER_TRELLO_ENABLED="false" \
    # Trello importer api key
    TAIGA_IMPORTER_TRELLO_API_KEY="" \
    # Trello importer secret key
    TAIGA_IMPORTER_TRELLO_SECRET_KEY="" \
    # Enable the JIRA project importer
    TAIGA_IMPORTER_JIRA_ENABLED="false" \
    # JIRA importer consumer key
    TAIGA_IMPORTER_JIRA_CONSUMER_KEY="" \
    # JIRA importer cert
    TAIGA_IMPORTER_JIRA_CERT="" \
    # JIRA importer public cert
    TAIGA_IMPORTER_JIRA_PUB_CERT="" \
    # Enable the Asana project importer
    TAIGA_IMPORTER_ASANA_ENABLED="false" \
    # Override callback URL for Asana importer. Will be automatically set based on Taiga URL if left blank.
    TAIGA_IMPORTER_ASANA_CALLBACK_URL="" \
    # Asana importer app ID
    TAIGA_IMPORTER_ASANA_APP_ID="" \
    # Asana importer app secret
    TAIGA_IMPORTER_ASANA_APP_SECRET="" \
    DEBUG=false \
    # Default container user id
    TAIGA_UID=1000 \
    # Default container group id
    TAIGA_GID=1000 \
    # List of plugins to enable eg. "slack, other, other" or just "slack"
    TAIGA_PLUGINS="" \
    # Interval (in seconds) for a background task that sends mails
    MAIL_NOTIFICATIONS_SEND_EVERY=120 \
    # The number of worker processes for handling requests
    GUNICORN_WORKERS=4 \
    # Workers silent for more than this many seconds are killed and restarted
    GUNICORN_TIMEOUT=60 \
    # The number of worker threads for handling requests
    GUNICORN_WORKER_THREADS=1 \
    # The maximum number of simultaneous clients
    GUNICORN_WORKER_CONNECTIONS=1000 \
    # The maximum number of requests a worker will process before restarting
    GUNICORN_WORKER_MAX_REQUESTS=3000 \
    # The granularity of Error log outputs
    GUNICRON_LOG_LEVEL=info \
    # The maximum number of pending connections
    GUNICORN_BACKLOG=2048 \
    # Enable or not the webhooks
    TAIGA_ENABLE_WEBHOOKS=False \
    RKD_PATH="/opt/rkd/.rkd"

COPY container-files/opt/rkd /opt/rkd
COPY bin/plugins/plugin-manager.py /opt/riotkit/bin/
COPY bin/cron/send-mail-notifications.sh /opt/riotkit/bin/
COPY bin/taiga/launch-gunicorn.sh /opt/riotkit/bin/
COPY plugins /usr/src/taiga-plugins

#
# Setup RKD
#
RUN pip install -r /opt/rkd/requirements.txt \
    && rkd :tasks

# install dependencies
# download and unpack applications in selected versions
# set a locale
# clean up
RUN set -x \
    && apt-get update \
    && apt-get install -y --no-install-recommends locales gettext ca-certificates nginx libcap2-bin supervisor wget curl subversion postgresql-client \
    && apt-get clean \
    \
    && echo "LANG=en_US.UTF-8" > /etc/default/locale \
    && echo "LC_TYPE=en_US.UTF-8" > /etc/default/locale \
    && echo "LC_MESSAGES=POSIX" >> /etc/default/locale \
    && echo "LANGUAGE=en" >> /etc/default/locale \
    && locale-gen en_US.UTF-8 && dpkg-reconfigure locales \
    && locale -a \
    \
    && addgroup --gid $TAIGA_GID taiga \
    && adduser taiga --uid $TAIGA_UID --home /usr/src --disabled-password --shell /bin/bash --gid $TAIGA_GID \
    && setcap cap_net_bind_service=ep /usr/sbin/nginx \
    \
    && wget https://github.com/taigaio/taiga-back/archive/$RKT_APP_VERSION.tar.gz -O /usr/src/taiga-back.tar.gz \
    && wget https://github.com/taigaio/taiga-front-dist/archive/$FRONTEND_VERSION.tar.gz -O /usr/src/taiga-front-dist.tar.gz \
    && cd /usr/src/ \
    && tar -xvf taiga-back.tar.gz \
    && mkdir -p /usr/src/taiga-back \
    && mv taiga-back-*/* taiga-back/ \
    \
    && tar -xvf taiga-front-dist.tar.gz \
    && mkdir -p /usr/src/taiga-front-dist \
    && mv taiga-front-*/* taiga-front-dist/ \
    \
    && rm /usr/src/*.tar.gz \
    \
    && mkdir -p /taiga /usr/src/taiga-front-dist/dist/js/ /usr/src/taiga-front-dist/dist/plugins \
    && pip install --no-cache-dir -r /usr/src/taiga-back/requirements.txt \
    && pip install --no-cache-dir j2cli \
    && pip install --no-cache-dir taiga-contrib-ldap-auth-ext \
    && chmod +x /opt/riotkit/bin/* \
    && mkdir -p /usr/src/taiga-plugins \
    && /opt/riotkit/bin/plugin-manager.py install-all-plugins


# Configure SSL ( Required for the LDAP plugin )
RUN echo "CipherString=DEFAULT@SECLEVEL=1" >> /etc/ssl/openssl.cnf

# copy configs and scripts
COPY container-files/opt/taiga-conf /opt/taiga-conf
COPY container-files/docker-entrypoint.sh /docker-entrypoint.sh
COPY container-files/etc/supervisor.conf /etc/supervisord.conf

# configure
RUN cp /opt/taiga-conf/taiga/local.py /usr/src/taiga-back/settings/local.py \
    && cp /opt/taiga-conf/taiga/docker.py /usr/src/taiga-back/settings/docker.py \
    && cp /opt/taiga-conf/taiga/celery.py /usr/src/taiga-back/settings/celery.py \
    && j2 /opt/taiga-conf/locale.gen.j2 > /etc/locale.gen \
    \
    # NOTICE: In case that "collectstatic" would not be found, it means in Django that the Taiga was not loaded
    # and only basic Django application is configured because of an error, so Taiga commands are not loaded in that case
    \
    && cd /usr/src/taiga-back/ && python manage.py collectstatic --noinput \
    && mkdir -p /var/log/nginx /var/lib/nginx \
    && touch /var/run/nginx.pid

EXPOSE 80 9001
VOLUME /usr/src/taiga-back/media
WORKDIR /usr/src/taiga-back

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["supervisord", "-c", "/etc/supervisord.conf"]

HEALTHCHECK --interval=1m --timeout=5s \
  CMD curl -s -f http://localhost/ || exit 1
