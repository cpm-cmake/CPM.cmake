#!/usr/bin/python3

import os

from pathlib import Path
from subprocess import PIPE, run

examples = [
    x for x in Path(__file__).parent.iterdir() if x.is_dir() and (x / 'CMakeLists.txt').exists() and (x.name != 'benchmark')
]

assert(len(examples) > 0)


def runCommand(command):
    print('- %s' % command)
    result = run(command, stdout=PIPE, stderr=PIPE, universal_newlines=True, shell=True)
    if result.returncode != 0:
        print("error while running '%s':\n" %
              command, '  ' + str(result.stderr).replace('\n', '\n  '))
        exit(result.returncode)
    return result.stdout


print('')
for example in examples:
    print("running example %s" % example.name)
    print("================" + ('=' * len(example.name)))
    project = Path(".") / 'build' / example.name
    cmakeModulesPath = os.environ['HOME'] + '/Workspace/cmake'
    before = "%s/before_project_setup.cmake" % (cmakeModulesPath)
    after = "%s/build_options.cmake" % (cmakeModulesPath)
    configure = runCommand(
        'cmake -H%s -B%s -G Ninja -DCMAKE_PROJECT_INCLUDE_BEFORE=%s -DCMAKE_PROJECT_INCLUDE=%s' % (example, project, before, after))
    print('  ' + '\n  '.join([line for line in configure.split('\n') if 'CPM:' in line]))
    build = runCommand('cmake --build %s -j8' % (project))
    print('  ' + '\n  '.join([line for line in build.split('\n') if 'Built target' in line]))
    print('')
