# Importing common provides default settings, see:
# https://github.com/taigaio/taiga-back/blob/master/settings/common.py
from .common import *
import os

DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.postgresql',
        'NAME': os.getenv('TAIGA_DB_NAME'),
        'HOST': os.getenv('TAIGA_DB_HOST'),
        'USER': os.getenv('TAIGA_DB_USER'),
        'PASSWORD': os.getenv('TAIGA_DB_PASSWORD')
    }
}

TAIGA_HOSTNAME = os.getenv('TAIGA_HOSTNAME', 'localhost')
TAIGA_SCHEME = os.getenv('TAIGA_SCHEME', 'http')

SITES['api']['domain'] = TAIGA_HOSTNAME
SITES['front']['domain'] = TAIGA_HOSTNAME

MEDIA_URL = TAIGA_SCHEME + '://' + TAIGA_HOSTNAME + '/media/'
STATIC_URL = TAIGA_SCHEME + '://' + TAIGA_HOSTNAME + '/static/'
SECRET_KEY = os.getenv('TAIGA_SECRET_KEY')

if os.getenv('TAIGA_REDIS_URL', '') and os.getenv('TAIGA_BROKER_URL', '') \
        and os.getenv('TAIGA_ENABLE_EVENTS', 'false').lower() == 'true':
    from .celery import *

    BROKER_URL = os.getenv('TAIGA_BROKER_URL', 'amqp://guest:guest@rabbit:5672')
    CELERY_RESULT_BACKEND = os.getenv('TAIGA_REDIS_URL', 'redis://redis:6379/0').replace('"', '')
    CELERY_ENABLED = True

    EVENTS_PUSH_BACKEND = "taiga.events.backends.rabbitmq.EventsPushBackend"
    EVENTS_PUSH_BACKEND_OPTIONS = {"url": BROKER_URL}

if os.getenv('TAIGA_ENABLE_EMAIL', '').lower() == 'true':
    DEFAULT_FROM_EMAIL = os.getenv('TAIGA_EMAIL_FROM')
    CHANGE_NOTIFICATIONS_MIN_INTERVAL = 300  # in seconds

    EMAIL_BACKEND = 'django.core.mail.backends.smtp.EmailBackend'
    EMAIL_USE_TLS = os.getenv('TAIGA_EMAIL_USE_TLS').lower() == 'true'

    EMAIL_HOST = os.getenv('TAIGA_EMAIL_HOST')
    EMAIL_PORT = int(os.getenv('TAIGA_EMAIL_PORT', 25))
    EMAIL_HOST_USER = os.getenv('TAIGA_EMAIL_USER')
    EMAIL_HOST_PASSWORD = os.getenv('TAIGA_EMAIL_PASS')

#
# LDAP Settings
#

if os.getenv('TAIGA_LDAP', '').lower() == 'true':
    INSTALLED_APPS += ['taiga_contrib_ldap_auth_ext']

LDAP_SERVER = os.getenv('LDAP_SERVER', '')
LDAP_PORT = int(os.getenv('LDAP_PORT', 0))

# Flag to enable LDAP with STARTTLS before bind
LDAP_START_TLS = os.getenv('LDAP_START_TLS', '').lower() == 'true'

# Full DN of the service account use to connect to LDAP server and search for login user's account entry
# If LDAP_BIND_DN is not specified, or is blank, then an anonymous bind is attempated
LDAP_BIND_DN = os.getenv('LDAP_BIND_DN', '')
LDAP_BIND_PASSWORD = os.getenv('LDAP_BIND_PASSWORD', '')

# Starting point within LDAP structure to search for login user
LDAP_SEARCH_BASE = os.getenv('LDAP_SEARCH_BASE', '')

# Additional search criteria to the filter (will be ANDed)
if os.getenv('LDAP_SEARCH_FILTER_ADDITIONAL', '') != '':
    LDAP_SEARCH_FILTER_ADDITIONAL = os.getenv('LDAP_SEARCH_FILTER_ADDITIONAL')

# Names of attributes to get username, e-mail and full name values from
# These fields need to have a value in LDAP
LDAP_USERNAME_ATTRIBUTE = os.getenv('LDAP_USERNAME_ATTRIBUTE', '')
LDAP_EMAIL_ATTRIBUTE = os.getenv('LDAP_EMAIL_ATTRIBUTE', '')
LDAP_FULL_NAME_ATTRIBUTE = os.getenv('LDAP_FULL_NAME_ATTRIBUTE', '')

# Option to not store the passwords in the local db.
LDAP_SAVE_LOGIN_PASSWORD = os.getenv('LDAP_SAVE_LOGIN_PASSWORD', 'true').lower() == 'true'

# Fallback on normal authentication method if LDAP auth fails. Set this to ''
# to disable fallback.
LDAP_FALLBACK = os.getenv('LDAP_FALLBACK', 'normal')
