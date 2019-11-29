
import subprocess
import sys

VERSION = '3.1'
PIP_PACKAGE = 'taiga-contrib-slack'
BACKEND_INSTALLED_APPS = ['taiga_contrib_slack']
FRONTEND_CONTRIB_PLUGINS = ['/plugins/slack/slack.json']


def after_application_migration():
    """ Executes on each container start in the entrypoint, after application was migrated """
    subprocess.check_call(
        'python3 manage.py migrate taiga_contrib_slack',
        shell=True
    )


def frontend_setup():
    """ Installs frontend at build time """

    subprocess.check_call(
        'svn export "https://github.com/taigaio/taiga-contrib-slack/tags/' + VERSION + '/front/dist" "slack"',
        shell=True,
        stdout=sys.stdout,
        stderr=sys.stderr
    )


def backend_setup():
    """ Installs backend at build time """

    subprocess.check_call(
        'pip3 install ' + PIP_PACKAGE + '==' + VERSION,
        shell=True,
        stdout=sys.stdout,
        stderr=sys.stderr
    )
