#!/usr/bin/env python3

"""
Plugins management for RiotKit's container for Taiga.io application
===================================================================

    Pre-installs all available plugins on container build,
    then lets *ops to decide which plugin to enable on container startup

License: MIT
Author: RiotKit Collective (https://github.com/riotkit-org)
"""

import os
import sys
import json
import importlib.util


class PluginManager:
    _front_path: str
    _plugins_path: str
    _plugins: dict

    def __init__(self):
        self._front_path = self._detect_front_path()
        self._plugins_path = self._detect_plugins_path()
        self._load_all()

    def install(self):
        """
        Command: Iterate over all AVAILABLE plugins and pre-install them. They can be enabled later.
        :return:
        """

        print(' >> Installing plugins...')
        print(list(self._plugins.items()))

        for plugin_name, module in self._plugins.items():
            print(' >> Instaling plugin "%s"' % plugin_name)

            os.chdir(self._front_path)
            print('   .. installing frontend')
            module.frontend_setup()

            print('   .. installing backend')
            module.backend_setup()

    def export_plugin_variables_to_environment(self):
        """
        Command: Enable SELECTED plugins
        :return:
        """

        enabled_plugins = os.getenv('TAIGA_PLUGINS', '').replace(' ', '').replace('"', '').strip().split(',')
        valid_plugins_list = str(list(self._plugins.keys())).replace('.py', '')

        frontend_contrib_plugins_list = []
        backend_installed_apps = []

        for enabled_plugin in enabled_plugins:
            if not enabled_plugin:
                continue

            if enabled_plugin not in self._plugins:
                raise Exception('Plugin name "%s" is invalid, valid options: %s' % (enabled_plugin, valid_plugins_list))

            module = self._plugins[enabled_plugin]
            frontend_contrib_plugins_list += module.FRONTEND_CONTRIB_PLUGINS
            backend_installed_apps += module.BACKEND_INSTALLED_APPS

        print('''
            export FRONTEND_CONTRIB_PLUGINS_LIST="%s";
            export BACKEND_INSTALLED_APPS="%s";
            ''' % (
                json.dumps(frontend_contrib_plugins_list).strip('[]').replace('"', '\\"'),
                json.dumps(backend_installed_apps).replace('"', '\\"')
            )
        )

    def _load_all(self):
        self._plugins = {}

        for filename in os.scandir(self._plugins_path):
            if not filename.name.endswith('.py'):
                continue

            plugin_name = os.path.basename(filename.name).replace('.py', '')
            self._plugins[plugin_name] = self._load(plugin_name, filename.path)

    @staticmethod
    def _load(plugin_name: str, path: str):
        spec = importlib.util.spec_from_file_location("dockertaiga.%s" % plugin_name, path)
        mod = importlib.util.module_from_spec(spec)
        spec.loader.exec_module(mod)

        return mod

    @staticmethod
    def _detect_plugins_path():
        if os.path.isdir('/usr/src/taiga-plugins'):
            return '/usr/src/taiga-plugins'

        return os.path.abspath(os.path.dirname(__file__) + '/../../plugins/')

    @staticmethod
    def _detect_front_path():
        if os.path.isfile('/usr/src/taiga-front-dist/dist/plugins'):
            return '/usr/src/taiga-front-dist/dist/plugins'

        return '/tmp'


if __name__ == '__main__':
    action = sys.argv[1] if len(sys.argv) > 1 else ''
    app = PluginManager()

    if action == 'install-all-plugins':
        app.install()

    elif action == 'export':
        app.export_plugin_variables_to_environment()
    else:
        print('Tasks: install-all-plugins, export')
        sys.exit(1)
