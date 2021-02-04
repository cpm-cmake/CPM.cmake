#!/usr/bin/python3

import os

from pathlib import Path
from subprocess import PIPE, run

# NOTE: boost V1.67 is to old! CK
examples = [
    x for x in Path(__file__).parent.iterdir() if x.is_dir() and (x / 'CMakeLists.txt').exists() and (not x.name in ['boost'])
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
    #
    # Note: needs at least cmake V3.15! CK
    # https://cmake.org/cmake/help/latest/command/project.html#code-injection
    #
    cmakeModulesPath = os.environ['HOME'] + '/Workspace/cmake'
    if Path(cmakeModulesPath).is_dir():
        before = "-DCMAKE_PROJECT_INCLUDE_BEFORE=%s/before_project_setup.cmake" % (
            cmakeModulesPath)
        after = "-DCMAKE_PROJECT_INCLUDE=%s/build_options.cmake" % (cmakeModulesPath)

    configure = runCommand('cmake -H%s -B%s -G Ninja %s %s' % (example, project, before, after))
    print('  ' + '\n  '.join([line for line in configure.split('\n') if 'CPM:' in line]))
    build = runCommand('cmake --build %s -j8' % (project))
    print('  ' + '\n  '.join([line for line in build.split('\n') if 'Built target' in line]))
    print('')
