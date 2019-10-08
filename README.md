[![Build Status](https://travis-ci.com/TheLartians/CPM.svg?branch=master)](https://travis-ci.com/TheLartians/CPM)

<p align="center">
  <img src="./logo/CPM.png" height="100" />
</p>

# Setup-free CMake dependency management

CPM is a CMake script that adds dependency management capabilities to CMake.
It's built as a wrapper around CMake's [FetchContent](https://cmake.org/cmake/help/latest/module/FetchContent.html) module that adds version control and a simple API.

## Manage everything

Anything can be added as a version-controlled dependency though CPM, no packaging required.
Projects using CMake are automatically configured and their targets can be used immediately.
For everything else, a target can be created manually (see below).

## Usage

After `CPM.cmake` has been [added](#adding-cpm) to your project, the function `CPMAddPackage` can be used to fetch and configure a dependency.
Afterwards, any targets defined in the dependency can be used directly.
`CPMAddPackage` takes the following named parameters.

```cmake
CPMAddPackage(
  NAME          # The unique name of the dependency (should be the main target's name)
  VERSION       # The minimum version of the dependency (optional, defaults to 0)
  OPTIONS       # Configuration options passed to the dependency (optional)
  DOWNLOAD_ONLY # If set, the project is downloaded, but not configured (optional)
  [...]         # Origin paramters forwarded to FetchContent_Declare, see below
)
```

The origin may be specified by a `GIT_REPOSITORY`, but other sources, such as direct URLs, are [also supported](https://cmake.org/cmake/help/v3.11/module/ExternalProject.html#external-project-definition).
If `GIT_TAG` hasn't been explicitly specified it defaults to `v(VERSION)`, a common convention for git projects.
`GIT_TAG` can also be set to a specific commit or a branch name such as `master` to download the most recent version.

Besides downloading and to configuring the dependency, the following variables are defined in the local scope, where `(DEPENDENCY)` is the name of the dependency.

- `(DEPENDENCY)_SOURCE_DIR` is the path to the source of the dependency.
- `(DEPENDENCY)_BINARY_DIR` is the path to the build directory of the dependency.
- `(DEPENDENCY)_ADDED` is set to `YES` if the dependency has not been added before, otherwise it is set to `NO`.

## Full CMakeLists Example

```cmake
cmake_minimum_required(VERSION 3.14 FATAL_ERROR)

# create project
project(MyProject)

# add executable
add_executable(myProject myProject.cpp)
set_target_properties(myProject PROPERTIES CXX_STANDARD 17)

# add dependencies
include(cmake/CPM.cmake)

CPMAddPackage(
  NAME LarsParser
  VERSION 1.8
  GIT_REPOSITORY https://github.com/TheLartians/Parser.git
  OPTIONS
    "LARS_PARSER_BUILD_GLUE_EXTENSION ON"
)

target_link_libraries(myProject LarsParser)
```

See the [examples directory](https://github.com/TheLartians/CPM/tree/master/examples) for more examples with source code.

## Adding CPM

To add CPM to your current project, simply add `cmake/CPM.cmake` to your project's `cmake` directory. The command below will perform this automatically.

```bash
mkdir -p cmake
wget -O cmake/CPM.cmake https://raw.githubusercontent.com/TheLartians/CPM/master/cmake/CPM.cmake
```

You can also use CMake to download CPM for you. See the [wiki](https://github.com/TheLartians/CPM/wiki/Adding-CPM) for more details.

## Updating CPM

To update CPM to the newest version, simply update the script in the project's cmake directory, for example by running the command above. Dependencies using CPM will automatically use the updated script of the outermost project.

## Advantages

- **Small and reusable projects** CPM takes care of all project dependencies, allowing developers to focus on creating small, well-tested frameworks.
- **Cross-Platform** CPM adds projects via `add_subdirectory`, which is compatible with all cmake toolchains and generators.
- **Reproducable builds** By using versioning via git tags it is ensured that a project will always be in the same state everywhere.
- **Recursive dependencies** Ensures that no dependency is added twice and is added in the minimum required version.
- **Plug-and-play** No need to install anything. Just add the script to your project and you're good to go.
- **No packaging required** There is a good chance your existing projects already work as CPM dependencies.
- **Simple source distribution** CPM makes including projects with source files and dependencies easy, reducing the need for monolithic header files.

## Limitations

- **No pre-built binaries** For every new project, all dependencies must be downloaded and built from scratch. A possible workaround is to use CPM to fetch a pre-built binary or to enable local packages (see [below](#local-packages)).
- **Dependent on good CMakeLists** Many libraries do not have CMakeLists that work well for subprojects. Luckily this is slowly changing, however, until then, some manual configuration may be required (see the snippets [below](#snippets)). For best practices on preparing your projects for CPM, see the [wiki](https://github.com/TheLartians/CPM/wiki/Preparing-projects-for-CPM). 
- **First version used** In diamond-shaped dependency graphs (e.g. `A` depends on `C`@1.1 and `B`, which itself depends on `C`@1.2 the first added dependency will be used (in this case `C`@1.1). In this case, B requires a newer version of `C` than `A`, so CPM will emit an error. This can be resolved by updating the outermost dependency version.

For projects with more complex needs and where an extra setup step doesn't matter, it is worth to check out fully featured C++ package managers such as [conan](https://conan.io), [vcpkg](https://github.com/microsoft/vcpkg) or [hunter](https://github.com/ruslo/hunter).
Support for package managers is also [planned](https://github.com/TheLartians/CPM/issues/51) for a future version of CPM.

## Options

### CPM_SOURCE_ROOT

To avoid re-downloading dependencies, configure the project with the cmake option `-DCPM_SOURCE_ROOT=<path to an external download directory>`.
It may also be defined as an environmental variable.

### CPM_USE_LOCAL_PACKAGES

CPM can be configured to use `find_package` to search for locally installed dependencies first by setting the CMake option `CPM_USE_LOCAL_PACKAGES`.
If the option `CPM_LOCAL_PACKAGES_ONLY` is set, CPM will emit an error if the dependency is not found locally.

## Snippets

These examples demonstrate how to include some well-known projects with CPM.
See the [wiki](https://github.com/TheLartians/CPM/wiki/More-Snippets) for more snippets.

### [Catch2](https://github.com/catchorg/Catch2)

```cmake
CPMAddPackage(
  NAME Catch2
  GITHUB_REPOSITORY catchorg/Catch2
  VERSION 2.5.0
)
```

### [Boost (via boost-cmake)](https://github.com/Orphis/boost-cmake)

```CMake
CPMAddPackage(
  NAME boost-cmake
  GITHUB_REPOSITORY Orphis/boost-cmake
  VERSION 1.67.0
)
```

### [cxxopts](https://github.com/jarro2783/cxxopts)

```cmake
CPMAddPackage(
  NAME cxxopts
  GITHUB_REPOSITORY jarro2783/cxxopts
  VERSION 2.2.0
  OPTIONS
    "CXXOPTS_BUILD_EXAMPLES Off"
    "CXXOPTS_BUILD_TESTS Off"
)
```

### [Yaml-cpp](https://github.com/jbeder/yaml-cpp)

```CMake
CPMAddPackage(
  NAME yaml-cpp
  GITHUB_REPOSITORY jbeder/yaml-cpp
  # 0.6.2 uses depricated CMake syntax
  VERSION 0.6.3
  # 0.6.3 is not released yet, so use a recent commit
  GIT_TAG 012269756149ae99745b6dafefd415843d7420bb 
  OPTIONS
    "YAML_CPP_BUILD_TESTS Off"
    "YAML_CPP_BUILD_CONTRIB Off"
    "YAML_CPP_BUILD_TOOLS Off"
)
```

### [google/benchmark](https://github.com/google/benchmark)

```cmake
CPMAddPackage(
  NAME benchmark
  GITHUB_REPOSITORY google/benchmark
  VERSION 1.4.1
  OPTIONS
    "BENCHMARK_ENABLE_TESTING Off"
)

if (benchmark_ADDED)
  # compile with C++17
  set_target_properties(benchmark PROPERTIES CXX_STANDARD 17)
endif()
```

### [nlohmann/json](https://github.com/nlohmann/json)

```cmake
CPMAddPackage(
  NAME nlohmann_json
  VERSION 3.6.1  
  # the git repo is incredibly large, so we download the archived include directory
  URL https://github.com/nlohmann/json/releases/download/v3.6.1/include.zip
  URL_HASH SHA256=69cc88207ce91347ea530b227ff0776db82dcb8de6704e1a3d74f4841bc651cf
)

if (nlohmann_json_ADDED)
  add_library(nlohmann_json INTERFACE IMPORTED)
  target_include_directories(nlohmann_json INTERFACE ${nlohmann_json_SOURCE_DIR})
endif()
```

### [Range-v3](https://github.com/ericniebler/range-v3)

```Cmake
CPMAddPackage(
  NAME range-v3
  URL https://github.com/ericniebler/range-v3/archive/0.5.0.zip
  VERSION 0.5.0
  # the range-v3 CMakeLists screws with configuration options
  DOWNLOAD_ONLY True
)

if(range-v3_ADDED) 
  add_library(range-v3 INTERFACE IMPORTED)
  target_include_directories(range-v3 INTERFACE "${range-v3_SOURCE_DIR}/include")
endif()
```

### [Lua](https://www.lua.org)

```cmake
CPMAddPackage(
  NAME lua
  GIT_REPOSITORY https://github.com/lua/lua.git
  VERSION 5.3.5
  DOWNLOAD_ONLY YES
)

if (lua_ADDED)
  # lua has no CMake support, so we create our own target

  FILE(GLOB lua_sources ${lua_SOURCE_DIR}/*.c)
  add_library(lua STATIC ${lua_sources})

  target_include_directories(lua
    PUBLIC
      $<BUILD_INTERFACE:${lua_SOURCE_DIR}>
  )
endif()
```

For a full example on using CPM to download and configure lua with sol2 see [here](examples/sol2).

### Full Examples

See the [examples directory](https://github.com/TheLartians/CPM/tree/master/examples) for full examples with source code.
