
import subprocess

VERSION = '3.1'
PIP_PACKAGE = 'taiga-contrib-slack'
BACKEND_INSTALLED_APPS = ['taiga_contrib_slack']
FRONTEND_CONTRIB_PLUGINS = ['/plugins/slack/slack.json']


def frontend_setup():
    subprocess.check_call(
        'svn export "https://github.com/taigaio/taiga-contrib-slack/tags/' + VERSION + '/front/dist" "slack"',
        shell=True
    )


def backend_setup():
    subprocess.check_call(
        'pip3 install ' + PIP_PACKAGE + '==' + VERSION,
        shell=True
    )
