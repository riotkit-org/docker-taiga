#!/usr/bin/env bash

#
# Simple background task that sends queued e-mails
#   - Does not interrupt on failure
#   - Controlled by supervisord, logs are grabbed by supervisor
#   - Shows logs on stdout and stderr
#   - Does not introduce additional dependencies on cron, exim and 60mb+ of others
#

cd /usr/src/taiga-back

MAIL_NOTIFICATIONS_SEND_EVERY=${MAIL_NOTIFICATIONS_SEND_EVERY:-120}

while true; do
    sleep ${MAIL_NOTIFICATIONS_SEND_EVERY}
    echo " >> Sending all queued mails"
    python manage.py send_notifications; exit_code=$?
    echo " >> Done, exit code is ${exit_code}"
done
