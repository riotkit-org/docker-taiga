# -*- coding: utf-8 -*-
# Copyright (C) 2014-2017 Andrey Antukh <niwi@niwi.nz>
# Copyright (C) 2014-2017 Jesús Espino <jespinog@gmail.com>
# Copyright (C) 2014-2017 David Barragán <bameda@dbarragan.com>
# Copyright (C) 2014-2017 Alejandro Alonso <alejandro.alonso@kaleidos.net>
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

from kombu import Queue

broker_url = os.getenv('TAIGA_BROKER_URL', 'amqp://guest:guest@rabbit:5672')
result_backend = os.getenv('TAIGA_REDIS_URL', 'redis://redis:6379/0').replace('"', '')

configured_serializer_type = os.getenv('CELERY_SERIALIZER_TYPE', 'pickle').replace('"', '')

accept_content = [configured_serializer_type,] # Values are 'pickle', 'json', 'msgpack' and 'yaml'
task_serializer = configured_serializer_type
result_serializer = configured_serializer_type

timezone = os.getenv('TZ', 'Europe/Warsaw').replace('"', '')

task_default_queue = 'tasks'
task_queues = (
    Queue('tasks', routing_key='task.#'),
    Queue('transient', routing_key='transient.#', delivery_mode=1)
)
task_default_exchange = 'tasks'
task_default_exchange_type = 'topic'
task_default_routing_key = 'task.default'
