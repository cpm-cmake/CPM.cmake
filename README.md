[![Build Status](https://travis-ci.com/TheLartians/CPM.svg?branch=master)](https://travis-ci.com/TheLartians/CPM)

# CPM

CPM is a simple GIT dependency manager written in CMake. The main use-case is abstracting CMake's `FetchContent` and managing dependencies in small to medium sized projects.

# Supported projects

Any project that you can add via `add_subdirectory` should already work with CPM.

# Usage

To add a new dependency to your project simply add the Projects target name, the git URL and the version. If the git tag for this version does not match the pattern `v$VERSION`, then the exact branch or tag can be specified with the `GIT_TAG` argument. CMake options can also be supplied with the package.

```cmake
cmake_minimum_required(VERSION 3.14 FATAL_ERROR)

# create project
project(MyProject)

# add dependencies
include(${CMAKE_CURRENT_SOURCE_DIR}/cmake/CPM.cmake)

CPMAddPackage(
  NAME LarsParser
  VERSION 1.8
  GIT_REPOSITORY https://github.com/TheLartians/Parser.git
  GIT_TAG v1.8 # optional here, as indirectly defined by VERSION
  OPTIONS      # optional CMake arguments passed to the dependency
    "LARS_PARSER_BUILD_GLUE_EXTENSION ON"
)

# add executable
add_executable(my-project my-project.cpp)
set_target_properties(my-project PROPERTIES CXX_STANDARD 17)
target_link_libraries(my-project LarsParser)
```

See the [examples directory](https://github.com/TheLartians/CPM/tree/master/examples) for more examples.

# Adding CPM

To add CPM to your current project, simply include add `cmake/CPM.cmake` to your projects `cmake` directory. The command below will perform this automatically.

```bash
wget -O cmake/CPM.cmake https://raw.githubusercontent.com/TheLartians/CPM/master/cmake/CPM.cmake
```

# Updating CPM

To update CPM to the newest version, simply run the script again in the projects directory. Dependencies using CPM will automatically use the updated script of the outermost project.

# Options

If you set the CMake option `CPM_REMOTE_PACKAGES_ONLY` to `On`, packages will always be fetched via the URL. Setting `CPM_LOCAL_PACKAGES_ONLY` to `On` will only add packages via `find_package`.

# Advantages

- **Small repos** CPM takes care of project dependencies, allowing you to focus on creating small, well-tested frameworks.
- **Cross-Plattform** CPM adds projects via `add_subdirectory`, which is compatible with all cmake toolchains and generators.
- **Reproducable builds** By using versioning via git tags it is ensured that a project will always be in the same state everywhere.
- **No installation required** No need to install anything. Just add the script to your project and you're good to go.
- **No Setup required** There is a good chance your existing projects already work as CPM dependencies.

# Limitations

- **First version used** In diamond-shaped dependency graphs (e.g. `A` depends on `C`(v1.1) and `A` depends on `B` depends on `C`(v1.2)) the first added dependency will be used (in this case `C`@1.1). If the current version is older than the version beeing added, or if provided options are incompatible, a CMake warning will be emitted.
- **No auto-update** To update a dependency, version numbers or git tags in the cmake scripts must be adapted manually.
