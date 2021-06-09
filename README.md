[![Build Status](https://travis-ci.com/cpm-cmake/CPM.cmake.svg?branch=master)](https://travis-ci.com/cpm-cmake/CPM.cmake)
[![Actions Status](https://github.com/cpm-cmake/CPM.cmake/workflows/MacOS/badge.svg)](https://github.com/cpm-cmake/CPM.cmake/actions)
[![Actions Status](https://github.com/cpm-cmake/CPM.cmake/workflows/Windows/badge.svg)](https://github.com/cpm-cmake/CPM.cmake/actions)
[![Actions Status](https://github.com/cpm-cmake/CPM.cmake/workflows/Ubuntu/badge.svg)](https://github.com/cpm-cmake/CPM.cmake/actions)

<br />
<p align="center">
  <img src="./logo/CPM.png" height="100" />
</p>
<br />

# Setup-free CMake dependency management

CPM.cmake is a CMake script that adds dependency management capabilities to CMake.
It's built as a thin wrapper around CMake's [FetchContent](https://cmake.org/cmake/help/latest/module/FetchContent.html) module that adds version control, caching, a simple API [and more](#comparison-to-pure-fetchcontent--externalproject).

## Manage everything

Any downloadable project or resource can be added as a version-controlled dependency though CPM, it is not necessary to modify or package anything.
Projects using modern CMake are automatically configured and their targets can be used immediately.
For everything else, the targets can be created manually after the dependency has been downloaded (see the [snippets](#snippets) below for examples).

## Further reading

- [CPM: An Awesome Dependency Manager for C++ with CMake](https://medium.com/swlh/cpm-an-awesome-dependency-manager-for-c-with-cmake-3c53f4376766)
- [CMake and the Future of C++ Package Management](https://ibob.github.io/blog/2020/01/13/cmake-package-management/)

## Usage

After `CPM.cmake` has been [added](#adding-cpm) to your project, the function `CPMAddPackage` can be used to fetch and configure a dependency.
Afterwards, any targets defined in the dependency can be used directly.
`CPMAddPackage` takes the following named parameters.

```cmake
CPMAddPackage(
  NAME          # The unique name of the dependency (should be the exported target's name)
  VERSION       # The minimum version of the dependency (optional, defaults to 0)
  OPTIONS       # Configuration options passed to the dependency (optional)
  DOWNLOAD_ONLY # If set, the project is downloaded, but not configured (optional)
  [...]         # Origin parameters forwarded to FetchContent_Declare, see below
)
```

The origin may be specified by a `GIT_REPOSITORY`, but other sources, such as direct URLs, are [also supported](https://cmake.org/cmake/help/v3.11/module/ExternalProject.html#external-project-definition).
If `GIT_TAG` hasn't been explicitly specified it defaults to `v(VERSION)`, a common convention for git projects.
On the other hand, if `VERSION` hasn't been explicitly specified, CPM can automatically identify the version from the git tag in some common cases.
`GIT_TAG` can also be set to a specific commit or a branch name such as `master`, however this isn't recommended, as such packages will only be updated when the cache is cleared.

If an additional optional parameter `EXCLUDE_FROM_ALL` is set to a truthy value, then any targets defined inside the dependency won't be built by default. See the [CMake docs](https://cmake.org/cmake/help/latest/prop_tgt/EXCLUDE_FROM_ALL.html) for details.

A single-argument compact syntax is also supported:

```cmake
# A git package from a given uri with a version
CPMAddPackage("uri@version")
# A git package from a given uri with a git tag or commit hash
CPMAddPackage("uri#tag")
# A git package with both version and tag provided
CPMAddPackage("uri@version#tag")
```

In the shorthand syntax if the URI is of the form `gh:user/name`, it is interpreted as GitHub URI and converted to `https://github.com/user/name.git`. If the URI is of the form `gl:user/name`, it is interpreted as a [GitLab](https://gitlab.com/explore/) URI and converted to `https://gitlab.com/user/name.git`. If the URI is of the form `bb:user/name`, it is interpreted as a [Bitbucket](https://bitbucket.org/) URI and converted to `https://bitbucket.org/user/name.git`. Otherwise the URI used verbatim as a git URL. All packages added using the shorthand syntax will be added using the [EXCLUDE_FROM_ALL](https://cmake.org/cmake/help/latest/prop_tgt/EXCLUDE_FROM_ALL.html) flag.

The single-argument syntax also works for URLs:

```cmake
# An archive package from a given url. The version is inferred
CPMAddPackage("https://example.com/my-package-1.2.3.zip")
# An archive package from a given url with an MD5 hash provided
CPMAddPackage("https://example.com/my-package-1.2.3.zip#MD5=68e20f674a48be38d60e129f600faf7d")
# An archive package from a given url. The version is explicitly given
CPMAddPackage("https://example.com/my-package.zip@1.2.3")
```

After calling `CPMAddPackage`, the following variables are defined in the local scope, where `<dependency>` is the name of the dependency.

- `<dependency>_SOURCE_DIR` is the path to the source of the dependency.
- `<dependency>_BINARY_DIR` is the path to the build directory of the dependency.
- `<dependency>_ADDED` is set to `YES` if the dependency has not been added before, otherwise it is set to `NO`.

For using CPM.cmake projects with external package managers, such as conan or vcpkg, setting the variable [`CPM_USE_LOCAL_PACKAGES`](#options) will make CPM.cmake try to add a package through `find_package` first, and add it from source if it doesn't succeed.

In rare cases, this behaviour may be desirable by default. The function `CPMFindPackage` will try to find a local dependency via CMake's `find_package` and fallback to `CPMAddPackage`, if the dependency is not found.

## Full CMakeLists Example

```cmake
cmake_minimum_required(VERSION 3.14 FATAL_ERROR)

# create project
project(MyProject)

# add executable
add_executable(tests tests.cpp)

# add dependencies
include(cmake/CPM.cmake)
CPMAddPackage("gh:catchorg/Catch2@2.5.0")

# link dependencies
target_link_libraries(tests Catch2)
```

See the [examples directory](https://github.com/cpm-cmake/CPM.cmake/tree/master/examples) for complete examples with source code and check [below](#snippets) or in the [wiki](https://github.com/cpm-cmake/CPM.cmake/wiki/More-Snippets) for example snippets.

## Adding CPM

To add CPM to your current project, simply add the [latest release](https://github.com/cpm-cmake/CPM.cmake/releases/latest) of `CPM.cmake` or `get_cpm.cmake` to your project's `cmake` directory.
The command below will perform this automatically.

```bash
mkdir -p cmake
wget -O cmake/CPM.cmake https://github.com/cpm-cmake/CPM.cmake/releases/latest/download/get_cpm.cmake
```

You can also download CPM.cmake directly from your project's `CMakeLists.txt`. See the [wiki](https://github.com/cpm-cmake/CPM.cmake/wiki/Downloading-CPM.cmake-in-CMake) for more details.

## Updating CPM

To update CPM to the newest version, update the script in the project's root directory, for example by running the command above.
Dependencies using CPM will automatically use the updated script of the outermost project.

## Advantages

- **Small and reusable projects** CPM takes care of all project dependencies, allowing developers to focus on creating small, well-tested libraries.
- **Cross-Platform** CPM adds projects directly at the configure stage and is compatible with all CMake toolchains and generators.
- **Reproducible builds** By versioning dependencies via git commits or tags it is ensured that a project will always be buildable.
- **Recursive dependencies** Ensures that no dependency is added twice and all are added in the minimum required version.
- **Plug-and-play** No need to install anything. Just add the script to your project and you're good to go.
- **No packaging required** Simply add all external sources as a dependency.
- **Simple source distribution** CPM makes including projects with source files and dependencies easy, reducing the need for monolithic header files or git submodules.

## Limitations

- **No pre-built binaries** For every new build directory, all dependencies are initially downloaded and built from scratch. To avoid extra downloads it is recommend to set the [`CPM_SOURCE_CACHE`](#CPM_SOURCE_CACHE) environmental variable. Using a caching compiler such as [ccache](https://github.com/TheLartians/Ccache.cmake) can drastically reduce build time.
- **Dependent on good CMakeLists** Many libraries do not have CMakeLists that work well for subprojects. Luckily this is slowly changing, however, until then, some manual configuration may be required (see the snippets [below](#snippets) for examples). For best practices on preparing projects for CPM, see the [wiki](https://github.com/cpm-cmake/CPM.cmake/wiki/Preparing-projects-for-CPM.cmake).
- **First version used** In diamond-shaped dependency graphs (e.g. `A` depends on `C`@1.1 and `B`, which itself depends on `C`@1.2 the first added dependency will be used (in this case `C`@1.1). In this case, B requires a newer version of `C` than `A`, so CPM will emit a warning. This can be easily resolved by adding a new version of the dependency in the outermost project, or by introducing a [package lock file](#package-lock).

For projects with more complex needs and where an extra setup step doesn't matter, it may be worth to check out an external C++ package manager such as [vcpkg](https://github.com/microsoft/vcpkg), [conan](https://conan.io) or [hunter](https://github.com/ruslo/hunter).
Dependencies added with `CPMFindPackage` should work with external package managers.
Additionally, the option [`CPM_USE_LOCAL_PACKAGES`](#cpmuselocalpackages) will enable `find_package` for all CPM dependencies.

## Comparison to FindPackage

The usual way to add libraries in CMake projects is to call `find_package(<PackageName>)` and to link against libraries defined in a `<PackageName>_LIBRARIES` variable.
While simple, this may lead to unpredictable builds, as it requires the library to be installed on the system and it is unclear which version of the library has been added.
Additionally, it is difficult to cross-compile projects (e.g. for mobile), as the dependencies will need to be rebuilt manually for each targeted architecture.

CPM.cmake allows dependencies to be unambiguously defined and builds them from source.
Note that the behaviour differs from `find_package`, as variables exported to the parent scope (such as  `<PackageName>_LIBRARIES`) will not be visible after adding a package using CPM.cmake.
The behaviour can be [achieved manually](https://github.com/cpm-cmake/CPM.cmake/issues/132#issuecomment-644955140), if required.

## Comparison to pure FetchContent / ExternalProject

CPM.cmake is a wrapper for CMake's FetchContent module and adds a number of features that turn it into a useful dependency manager.
The most notable features are:

- A simpler to use API
- Version checking: CPM.cmake will check the version number of any added dependency and emit a warning if another dependency requires a more recent version.
- Offline builds: CPM.cmake will override CMake's download and update commands, which allows new builds to be configured while offline if all dependencies [are available locally](#cpm_source_cache).
- Automatic shallow clone: if a version tag (e.g. `v2.2.0`) is provided and `CPM_SOURCE_CACHE` is used, CPM.cmake will perform a shallow clone of the dependency, which should be significantly faster while using less storage than a full clone.
- Overridable: all `CPMAddPackage` can be configured to use `find_package` by setting a [CMake flag](#cpm_use_local_packages), making it easy to integrate into projects that may require local versioning through the system's package manager.
- [Package lock files](#package-lock) for easier transitive dependency management.
- Dependencies can be overridden [per-build](#local-package-override) using CMake CLI parameters.

ExternalProject works similarly as FetchContent, however waits with adding dependencies until build time.
This has a quite a few disadvantages, especially as it makes using custom toolchains / cross-compiling very difficult and can lead to problems with nested dependencies.

## Options

### CPM_SOURCE_CACHE

To avoid re-downloading dependencies, CPM has an option `CPM_SOURCE_CACHE` that can be passed to CMake as `-DCPM_SOURCE_CACHE=<path to an external download directory>`.
This will also allow projects to be configured offline, as long as the dependencies have been added to the cache before.
It may also be defined system-wide as an environmental variable, e.g. by exporting `CPM_SOURCE_CACHE` in your `.bashrc` or `.bash_profile`.

```bash
export CPM_SOURCE_CACHE=$HOME/.cache/CPM
```

Note that passing the variable as a configure option to CMake will always override the value set by the environmental variable.

You can use `CPM_SOURCE_CACHE` on GitHub Actions workflows [cache](https://github.com/actions/cache) and combine it with ccache, to make your CI faster. See the [wiki](https://github.com/cpm-cmake/CPM.cmake/wiki/Caching-with-CPM.cmake-and-ccache-on-GitHub-Actions) for more info.

### CPM_DOWNLOAD_ALL

If set, CPM will forward all calls to `CPMFindPackage` as `CPMAddPackage`.
This is useful to create reproducible builds or to determine if the source parameters have all been set correctly.
This can also be set as an environmental variable.

### CPM_USE_LOCAL_PACKAGES

CPM can be configured to use `find_package` to search for locally installed dependencies first by setting the CMake option `CPM_USE_LOCAL_PACKAGES`.
If the option `CPM_LOCAL_PACKAGES_ONLY` is set, CPM will emit an error if the dependency is not found locally.
These options can also be set as environmental variables.

In the case that `find_package` requires additional arguments, the parameter `FIND_PACKAGE_ARGUMENTS` may be specified in the `CPMAddPackage` call. The value of this parameter will be forwarded to `find_package`.

## Local package override

Library developers are often in the situation where they work on a locally checked out dependency at the same time as on a consumer project.
It is possible to override the consumer's dependency with the version by supplying the CMake option `CPM_<dependency name>_SOURCE` set to the absolute path of the local library.
For example, to use the local version of the dependency `Dep` at the path `/path/to/dep`, the consumer can be built with the following command.

```bash
cmake -Bbuild -DCPM_Dep_SOURCE=/path/to/dep
```

## Package lock

In large projects with many transitive dependencies, it can be useful to introduce a package lock file.
This will list all CPM.cmake dependencies and can be used to update dependencies without modifying the original `CMakeLists.txt`.
To use a package lock, add the following line directly after including CPM.cmake.

```cmake
CPMUsePackageLock(package-lock.cmake)
```

To create or update the package lock file, build the `cpm-update-package-lock` target.

```bash
cmake -Bbuild
cmake --build build --target cpm-update-package-lock
```

See the [wiki](https://github.com/cpm-cmake/CPM.cmake/wiki/Package-lock) for more info.

## Built with CPM.cmake

Some amazing projects that are built using the CPM.cmake package manager.
If you know others, feel free to add them here through a PR.

<table>
  <tr>
    <td>
      <a href="https://bitfieldaudio.com">
        <p align="center">
          <img src="https://avatars2.githubusercontent.com/u/40357059?s=200&v=4"  alt="otto-project" height=100pt width=100pt />
        </p>
        <p align="center"><b>OTTO - The Open Source GrooveBox</b></p>
      </a>
    </td>
    <td>
      <a href="https://maphi.app">
        <p align="center">
          <img src="https://user-images.githubusercontent.com/4437447/89892751-71af8000-dbd7-11ea-9d87-4fe107845069.png"  alt="maphi" height=100pt width=100pt />
        </p>
        <p align="center"><b>Maphi - the Math App</b></p>
      </a>
    </td>
    <td>
      <a href="https://github.com/TheLartians/ModernCppStarter">
        <p align="center">
          <img src="https://repository-images.githubusercontent.com/254842585/4dfa7580-7ffb-11ea-99d0-46b8fe2f4170"  alt="modern-cpp-starter" height=100pt width=200pt />
        </p>
        <p align="center"><b>ModernCppStarter</b></p>
      </a>
    </td>
  </tr>
</table>

## Snippets

These examples demonstrate how to include some well-known projects with CPM.
See the [wiki](https://github.com/cpm-cmake/CPM.cmake/wiki/More-Snippets) for more snippets.

### [Catch2](https://github.com/catchorg/Catch2)

```cmake
CPMAddPackage("gh:catchorg/Catch2@2.5.0")
```

### [Boost (via boost-cmake)](https://github.com/Orphis/boost-cmake)

```CMake
# boost-cmake currently doesn't tag versions, so we use the according boost version
CPMAddPackage("gh:Orphis/boost-cmake#7f97a08b64bd5d2e53e932ddf80c40544cf45edf@1.71.0")
```

### [Yaml-cpp](https://github.com/jbeder/yaml-cpp)

```CMake
# as the tag is in an unusual format, we need to explicitly specify the version
CPMAddPackage("gh:jbeder/yaml-cpp#yaml-cpp-0.6.3@0.6.3")
```

### [Range-v3](https://github.com/ericniebler/range-v3)

```Cmake
CPMAddPackage("gh:ericniebler/range-v3#0.11.0")
```

### [nlohmann/json](https://github.com/nlohmann/json)

```cmake
CPMAddPackage(
  NAME nlohmann_json
  VERSION 3.9.1
  OPTIONS 
    "JSON_BuildTests OFF"
)
```

### [cxxopts](https://github.com/jarro2783/cxxopts)

```cmake
# the install option has to be explicitly set to allow installation
CPMAddPackage(
  GITHUB_REPOSITORY jarro2783/cxxopts
  VERSION 2.2.1
  OPTIONS "CXXOPTS_BUILD_EXAMPLES NO" "CXXOPTS_BUILD_TESTS NO" "CXXOPTS_ENABLE_INSTALL YES"
)
```

### [google/benchmark](https://github.com/google/benchmark)

```cmake
CPMAddPackage(
  NAME benchmark
  GITHUB_REPOSITORY google/benchmark
  VERSION 1.5.2
  OPTIONS "BENCHMARK_ENABLE_TESTING Off"
)

if(benchmark_ADDED)
  # enable c++11 to avoid compilation errors
  set_target_properties(benchmark PROPERTIES CXX_STANDARD 11)
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
  list(REMOVE_ITEM lua_sources "${lua_SOURCE_DIR}/lua.c" "${lua_SOURCE_DIR}/luac.c")
  add_library(lua STATIC ${lua_sources})

  target_include_directories(lua
    PUBLIC
      $<BUILD_INTERFACE:${lua_SOURCE_DIR}>
  )
endif()
```

For a full example on using CPM to download and configure lua with sol2 see [here](examples/sol2).

### Full Examples

See the [examples directory](https://github.com/cpm-cmake/CPM.cmake/tree/master/examples) for full examples with source code and check out the [wiki](https://github.com/cpm-cmake/CPM.cmake/wiki/More-Snippets) for many more example snippets.
