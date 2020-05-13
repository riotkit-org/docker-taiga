
from rkd.standardlib.python import imports as PythonImports
from rkd.standardlib.docker import imports as DockerImports
from rkt_ciutils.boatci import imports as BoatCIImports

# optionally, import docker-related and python-related tasks from Python packages
IMPORTS = [] + PythonImports() + DockerImports() + BoatCIImports()

# optionally, create own tasks that are using other tasks
TASKS = []
