[![Build Status](https://travis-ci.com/TheLartians/CPM.svg?branch=master)](https://travis-ci.com/TheLartians/CPM)

# CPM

CPM is a simple dependency manager written in CMake built on top of CMake's built-in [FetchContent](https://cmake.org/cmake/help/latest/module/FetchContent.html) module.

## Supported projects

Any project that you can add via `add_subdirectory` should already work with CPM.

## Usage

After `CPM.cmake` has been added to your project, you can call `CPMAddPackage` for every dependency of the project with the following named parameters.

```cmake
CPMAddPackage(
  NAME          # The dependency name (usually chosen to match the target name)
  VERSION       # The minimum version of the dependency (optional, defaults to 0)
  OPTIONS       # Configuration options passed to the dependency (optional)
  DOWNLOAD_ONLY # If set, the project is downloaded, but not configured (optional)
  [...]         # Source options, see below
)
```

The command downloads the project defined by the source options if a newer version hasn't been included before.
The source is usually a git repository, but svn and direct urls are als supported.
See the [FetchContent](https://cmake.org/cmake/help/latest/module/FetchContent.html) documentation for all available options.
If a `GIT_TAG` hasn't been explicitly specified it defaults to `v$VERSION` which is a common convention for github projects.

After calling `CPMAddPackage`, the variables `(DEPENDENCY)_SOURCE_DIR` and `(DEPENDENCY)_BINARY_DIR` are set, where `(PACKAGE)` is the name of the dependency.

## Example

```cmake
cmake_minimum_required(VERSION 3.14 FATAL_ERROR)

# create project
project(MyProject)

# add dependencies
include(cmake/CPM.cmake)

CPMAddPackage(
  NAME LarsParser
  VERSION 1.8
  GIT_REPOSITORY https://github.com/TheLartians/Parser.git
  OPTIONS
    "LARS_PARSER_BUILD_GLUE_EXTENSION ON"
)

# add executable
add_executable(myProject myProject.cpp)
set_target_properties(myProject PROPERTIES CXX_STANDARD 17)
target_link_libraries(myProject LarsParser)
```

See the [examples directory](https://github.com/TheLartians/CPM/tree/master/examples) for full examples with source.

## Adding CPM

To add CPM to your current project, simply add `cmake/CPM.cmake` to your project's `cmake` directory. The command below will perform this automatically.

```bash
wget -O cmake/CPM.cmake https://raw.githubusercontent.com/TheLartians/CPM/master/cmake/CPM.cmake
```

## Updating CPM

To update CPM to the newest version, simply update the script in the project's cmake directory, for example by running the command above. Dependencies using CPM will automatically use the updated script of the outermost project.

## Snipplets

These are some small snipplets demonstrating how to include some projects used with CPM.

### Catch2

Has a CMakeLists.txt that supports `add_subdirectory`.

```cmake
CPMAddPackage(
  NAME Catch2
  GIT_REPOSITORY https://github.com/catchorg/Catch2.git
  VERSION 2.5.0
)
```

### google/benchmark

Has a CMakeLists.txt that supports `add_subdirectory`, but needs some configuring to work without external dependencies.

```cmake
CPMAddPackage(
  NAME benchmark
  GIT_REPOSITORY https://github.com/google/benchmark.git
  VERSION 1.4.1
  OPTIONS
   "BENCHMARK_ENABLE_TESTING Off"
)

# needed to compile with C++17
set_target_properties(benchmark PROPERTIES CXX_STANDARD 17)
```

### Lua

Has no CMakeLists.txt, so a target must be created manually.

```cmake
CPMAddPackage(
  NAME lua
  GIT_REPOSITORY https://github.com/lua/lua.git
  VERSION 5-3-4
  GIT_SHALLOW YES
  DOWNLOAD_ONLY YES
)

FILE(GLOB lua_sources ${lua_SOURCE_DIR}/*.c)
add_library(lua STATIC ${lua_sources})

target_include_directories(lua
  PUBLIC
    $<BUILD_INTERFACE:${lua_SOURCE_DIR}>
)
```

## Local packages

CPM can be configured to use `find_package` to search for locally installed dependencies first.
If `CPM_LOCAL_PACKAGES_ONLY` is set, CPM will error when dependency is not found locally.

## Advantages

- **Small repos** CPM takes care of project dependencies, allowing you to focus on creating small, well-tested frameworks.
- **Cross-Plattform** CPM adds projects via `add_subdirectory`, which is compatible with all cmake toolchains and generators.
- **Reproducable builds** By using versioning via git tags it is ensured that a project will always be in the same state everywhere.
- **No installation required** No need to install anything. Just add the script to your project and you're good to go.
- **No Setup required** There is a good chance your existing projects already work as CPM dependencies.
- **Simple source distribution** CPM makes including projects with source files easy, reducing the need for monolithic header files.

## Limitations

- **First version used** In diamond-shaped dependency graphs (e.g. `A` depends on `C`(v1.1) and `A` depends on `B` depends on `C`(v1.2)) the first added dependency will be used (in this case `C`@1.1). If the current version is older than the version beeing added, or if provided options are incompatible, a CMake warning will be emitted. To resolve, add the new version of the common dependency to the outer project.
- **No auto-update** To update a dependency, version numbers or git tags in the cmake scripts must be adapted manually.
- **No pre-built binaries** Unless they are installed or included in the linked repository. 

For projects with more complex needs and where the extra setup does not matter, check out fully featured C++ package managers such as [conan](https://conan.io) or [hunter](https://github.com/ruslo/hunter) instead.
