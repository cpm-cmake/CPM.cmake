[![Build Status](https://travis-ci.com/TheLartians/CPM.svg?branch=master)](https://travis-ci.com/TheLartians/CPM)

# CPM

CPM is a CMake script that adds dependency management capabilities to CMake. 
It's built as an extension of CMake's [FetchContent](https://cmake.org/cmake/help/latest/module/FetchContent.html) module that adds version control and simpler usage.

## Supported projects

Any project that you can add via `add_subdirectory` should already work with CPM.
For everything else, targets must be created manually (see below).

## Usage

After `CPM.cmake` has been added to your project, the function `CPMAddPackage` can be used to fetch and configure all dependencies.
Afterwards all targets defined in the dependencies can be used.
`CPMAddPackage` takes the following named arguments.

```cmake
CPMAddPackage(
  NAME          # The name of the dependency (should be chosen to match the main target's name)
  VERSION       # The minimum version of the dependency (optional, defaults to 0)
  OPTIONS       # Configuration options passed to the dependency (optional)
  DOWNLOAD_ONLY # If set, the project is downloaded, but not configured (optional)
  [...]         # Origin paramters forwarded to FetchContent_Declare, see below
)
```

The origin is usually specified by a `GIT_REPOSITORY`, but [svn revisions and direct URLs are also supported](https://cmake.org/cmake/help/v3.11/module/ExternalProject.html#external-project-definition).
If `GIT_TAG` hasn't been explicitly specified it defaults to `v(VERSION)`, a common convention for github projects.
`GIT_TAG` can also be set to a branch name such as `master` to download the most recent version.

Besides downloading and to configuring the dependency, the following variables are defined in the local scope, where `(DEPENDENCY)` is the name of the dependency.

- `(DEPENDENCY)_SOURCE_DIR` is the path to the source of the dependency.
- `(DEPENDENCY)_BINARY_DIR` is the path to the build directory of the dependency.
- `(DEPENDENCY)_ADDED` is set to `YES` if the dependency has not been added before, otherwise it is set to `NO`.

## Full Example

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

See the [examples directory](https://github.com/TheLartians/CPM/tree/master/examples) for more examples with source code.

## Adding CPM

To add CPM to your current project, simply add `cmake/CPM.cmake` to your project's `cmake` directory. The command below will perform this automatically.

```bash
mkdir -p cmake
wget -O cmake/CPM.cmake https://raw.githubusercontent.com/TheLartians/CPM/master/cmake/CPM.cmake
```

## Updating CPM

To update CPM to the newest version, simply update the script in the project's cmake directory, for example by running the command above. Dependencies using CPM will automatically use the updated script of the outermost project.

## Advantages

- **Small and reusable projects** CPM takes care of project dependencies, no matter where they reside, allowing developers to focus on creating small, well-tested frameworks.
- **Cross-Plattform** CPM adds projects via `add_subdirectory`, which is compatible with all cmake toolchains and generators.
- **Reproducable builds** By using versioning via git tags it is ensured that a project will always be in the same state everywhere.
- **Recursive dependencies** Ensures that no dependency is added twice and is added in the minimum required version.
- **Plug-and-play** No need to install anything. Just add the script to your project and you're good to go.
- **No packaging required** There is a good chance your existing projects already work as CPM dependencies.
- **Simple source distribution** CPM makes including projects with source files and dependencies easy, reducing the need for monolithic header files.

## Limitations

- **No pre-built binaries** For every new project, all dependencies must be downloaded and built from scratch. A possible workaround is to use CPM to fetch a pre-built binary or to enable local packages (see below).
- **Dependency names** Shared dependencies must always be added with the exact same name as otherwise the same target may be added twice to the project. It is therefore highly recommended to choose the name exactly as the target defined in the dependency.
- **First version used** In diamond-shaped dependency graphs (e.g. `A` depends on `C`@1.1 and `B`, which itself depends on `C`@1.2 the first added dependency will be used (in this case `C`@1.1). In this case, B requires a newer version of `C` than `A`, so CPM will emit an error. This can be resolved by updating the outermost dependency version.
- **No auto-update** To update a dependency, version must be adapted manually and there is no way for CPM to figure out the most recent version.

For projects with more complex needs and where an extra setup step doesn't matter, it is worth to check out fully featured C++ package managers such as [conan](https://conan.io) or [hunter](https://github.com/ruslo/hunter).

## Local packages

CPM can be configured to use `find_package` to search for locally installed dependencies first by setting the CMake option `CPM_USE_LOCAL_PACKAGES`.
If the option `CPM_LOCAL_PACKAGES_ONLY` is set, CPM will emit an error when dependency is not found locally.

## Snipplets

These examples demonstrate how to include some well-known projects with CPM.

### [Catch2](https://github.com/catchorg/Catch2.git)

Has a CMakeLists.txt that supports `add_subdirectory`.

```cmake
CPMAddPackage(
  NAME Catch2
  GITHUB_REPOSITORY catchorg/Catch2
  VERSION 2.5.0
)
```

See [here](https://github.com/TheLartians/CPM/blob/master/examples/doctest/CMakeLists.txt) for doctest example.
Note that we can shorten Github and Gitlab URLs by using `GITHUB_REPOSITORY` or `GITLAB_REPOSITORY`, respectively.

### [google/benchmark](https://github.com/google/benchmark.git)

Has a CMakeLists.txt that supports `add_subdirectory`, but needs some configuring to work without external dependencies.

```cmake
CPMAddPackage(
  NAME benchmark
  GITHUB_REPOSITORY google/benchmark
  VERSION 1.4.1
  OPTIONS
    "BENCHMARK_ENABLE_TESTING Off"
)

# needed to compile with C++17
set_target_properties(benchmark PROPERTIES CXX_STANDARD 17)
```

### [nlohmann/json](https://github.com/nlohmann/json)

Header-only library with a huge git repositoy.
Instead of downloading the whole repositoy which would take a long time, we fetch the zip included with the release and create our own target.

```cmake
CPMAddPackage(
  NAME nlohmann_json
  VERSION 3.6.1  
  URL https://github.com/nlohmann/json/releases/download/v3.6.1/include.zip
  URL_HASH SHA256=69cc88207ce91347ea530b227ff0776db82dcb8de6704e1a3d74f4841bc651cf
)

if (nlohmann_json_ADDED)
  add_library(nlohmann_json INTERFACE IMPORTED)
  target_include_directories(nlohmann_json INTERFACE ${nlohmann_json_SOURCE_DIR})
endif()
```

Note the check for `nlohmann_json_ADDED`, before creating the target. This ensures that the target hasn't been added before by another dependency. 

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

Lua does not oficially support CMake, so we query the sources and create our own target.

```cmake
CPMAddPackage(
  NAME lua
  GIT_REPOSITORY https://github.com/lua/lua.git
  VERSION 5-3-4
  DOWNLOAD_ONLY YES
)

if (lua_ADDED)
  FILE(GLOB lua_sources ${lua_SOURCE_DIR}/*.c)
  add_library(lua STATIC ${lua_sources})

  target_include_directories(lua
    PUBLIC
      $<BUILD_INTERFACE:${lua_SOURCE_DIR}>
  )
endif()
```

### Examples

See the [examples directory](https://github.com/TheLartians/CPM/tree/master/examples) for more examples with source code.
