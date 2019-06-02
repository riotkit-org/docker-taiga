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
