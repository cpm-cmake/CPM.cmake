
<br />
<p align="center">
  <img src="./logo/CPM.png" height="100" />
</p>
<br />

# Setup-free CMake dependency management

CPM.cmake is a cross-platform CMake script that adds dependency management capabilities to CMake.
It's built as a thin wrapper around CMake's [FetchContent](https://cmake.org/cmake/help/latest/module/FetchContent.html) module that adds version control, caching, a simple API [and more](#comparison-to-pure-fetchcontent--externalproject).

## Manage everything

Any downloadable project or resource can be added as a version-controlled dependency through CPM, it is not necessary to modify or package anything.
Projects using modern CMake are automatically configured and their targets can be used immediately.
For everything else, the targets can be created manually after the dependency has been downloaded (see the [snippets](#snippets) below for examples).

## Further reading

- [CPM: An Awesome Dependency Manager for C++ with CMake](https://medium.com/swlh/cpm-an-awesome-dependency-manager-for-c-with-cmake-3c53f4376766)
- [CMake and the Future of C++ Package Management](https://ibob.github.io/blog/2020/01/13/cmake-package-management/)

## Full CMakeLists Example

```cmake
cmake_minimum_required(VERSION 3.14 FATAL_ERROR)

# create project
project(MyProject)

# add executable
add_executable(main main.cpp)

# add dependencies
include(cmake/CPM.cmake)

CPMAddPackage("gh:fmtlib/fmt#7.1.3")
CPMAddPackage("gh:nlohmann/json@3.10.5")
CPMAddPackage("gh:catchorg/Catch2@3.4.0")

# link dependencies
target_link_libraries(main fmt::fmt nlohmann_json::nlohmann_json Catch2::Catch2WithMain)
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

## Usage

After `CPM.cmake` has been [added](#adding-cpm) to your project, the function `CPMAddPackage` can be used to fetch and configure a dependency.
Afterwards, any targets defined in the dependency can be used directly.
`CPMAddPackage` takes the following named parameters.

```cmake
CPMAddPackage(
  NAME          # The unique name of the dependency (should be the exported target's name)
  VERSION       # The minimum version of the dependency (optional, defaults to 0)
  PATCHES       # Patch files to be applied sequentially using patch and PATCH_OPTIONS (optional)
  OPTIONS       # Configuration options passed to the dependency (optional)
  DOWNLOAD_ONLY # If set, the project is downloaded, but not configured (optional)
  [...]         # Origin parameters forwarded to FetchContent_Declare, see below
)
```

The origin may be specified by a `GIT_REPOSITORY`, but other sources, such as direct URLs, are [also supported](https://cmake.org/cmake/help/v3.11/module/ExternalProject.html#external-project-definition).
If `GIT_TAG` hasn't been explicitly specified it defaults to `v(VERSION)`, a common convention for git projects.
On the other hand, if `VERSION` hasn't been explicitly specified, CPM can automatically identify the version from the git tag in some common cases.
`GIT_TAG` can also be set to a specific commit or a branch name such as `master`, however this isn't recommended, as such packages will only be updated when the cache is cleared.

`PATCHES` takes a list of patch files to apply sequentially. For a basic example, see [Highway](examples/highway/CMakeLists.txt).
We recommend that if you use `PATCHES`, you also set `CPM_SOURCE_CACHE`. See [issue 577](https://github.com/cpm-cmake/CPM.cmake/issues/577).

If an additional optional parameter `EXCLUDE_FROM_ALL` is set to a truthy value, then any targets defined inside the dependency won't be built by default. See the [CMake docs](https://cmake.org/cmake/help/latest/prop_tgt/EXCLUDE_FROM_ALL.html) for details.

If an additional optional parameter `SYSTEM` is set to a truthy value, the SYSTEM directory property of the subdirectory added will be set to true.
See the [add_subdirectory ](https://cmake.org/cmake/help/latest/command/add_subdirectory.html?highlight=add_subdirectory)
and [SYSTEM](https://cmake.org/cmake/help/latest/prop_tgt/SYSTEM.html#prop_tgt:SYSTEM) target property for details.

A single-argument compact syntax is also supported:

```cmake
# A git package from a given uri with a version
CPMAddPackage("uri@version")
# A git package from a given uri with a git tag or commit hash
CPMAddPackage("uri#tag")
# A git package with both version and tag provided
CPMAddPackage("uri@version#tag")
```

In the shorthand syntax if the URI is of the form `gh:user/name`, it is interpreted as GitHub URI and converted to `https://github.com/user/name.git`. If the URI is of the form `gl:user/name`, it is interpreted as a [GitLab](https://gitlab.com/explore/) URI and converted to `https://gitlab.com/user/name.git`. If the URI is of the form `bb:user/name`, it is interpreted as a [Bitbucket](https://bitbucket.org/) URI and converted to `https://bitbucket.org/user/name.git`. Otherwise the URI used verbatim as a git URL. All packages added using the shorthand syntax will be added using the [EXCLUDE_FROM_ALL](https://cmake.org/cmake/help/latest/prop_tgt/EXCLUDE_FROM_ALL.html) and [SYSTEM](https://cmake.org/cmake/help/latest/prop_tgt/SYSTEM.html#prop_tgt:SYSTEM) flag.

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
- `CPM_LAST_PACKAGE_NAME` is set to the determined name of the last added dependency (equivalent to `<dependency>`).

For using CPM.cmake projects with external package managers, such as conan or vcpkg, setting the variable [`CPM_USE_LOCAL_PACKAGES`](#options) will make CPM.cmake try to add a package through `find_package` first, and add it from source if it doesn't succeed.

In rare cases, this behaviour may be desirable by default. The function `CPMFindPackage` will try to find a local dependency via CMake's `find_package` and fallback to `CPMAddPackage`, if the dependency is not found.

## Updating CPM

To update CPM to the newest version, update the script in the project's root directory, for example by running the same command as for [adding CPM](#adding-cpm).
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
- **Some CMake policies set to `NEW`** Including CPM.cmake will lead to several CMake policies being set to `NEW`. Users which need the old behavior will need to manually modify their CMake code to ensure they're set to `OLD` at the appropriate places. The policies are:
    - [CMP0077](https://cmake.org/cmake/help/latest/policy/CMP0077.html) and [CMP0126](https://cmake.org/cmake/help/latest/policy/CMP0126.html). They make setting package options from `CMPAddPackage` possible.
    - [CMP0135](https://cmake.org/cmake/help/latest/policy/CMP0135.html) It allows for proper package rebuilds of packages which are archives, source cache is not used, and the package URL is changed to an older version.
    - [CMP0150](https://cmake.org/cmake/help/latest/policy/CMP0150.html) Relative paths provided to `GIT_REPOSITORY` are treated as relative to the parent project's remote.

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

The directory where the version for a project is stored is by default the hash of the arguments to `CPMAddPackage()`.
If for instance the patch command uses external files, the directory name can be set with the argument `CUSTOM_CACHE_KEY`.

### CPM_DOWNLOAD_ALL

If set, CPM will forward all calls to `CPMFindPackage` as `CPMAddPackage`.
This is useful to create reproducible builds or to determine if the source parameters have all been set correctly.
This can also be set as an environmental variable.
This can be controlled on a per package basis with the `CPM_DOWNLOAD_<dependency name>` variable.

### CPM_USE_LOCAL_PACKAGES

CPM can be configured to use `find_package` to search for locally installed dependencies first by setting the CMake option `CPM_USE_LOCAL_PACKAGES`.

If the option `CPM_LOCAL_PACKAGES_ONLY` is set, CPM will emit an error if the dependency is not found locally.
These options can also be set as environmental variables.

In the case that `find_package` requires additional arguments, the parameter `FIND_PACKAGE_ARGUMENTS` may be specified in the `CPMAddPackage` call. The value of this parameter will be forwarded to `find_package`.

Note that this does not apply to dependencies that have been defined with a truthy `FORCE` parameter. These will be added as defined.

### CPM_DONT_UPDATE_MODULE_PATH

By default, CPM will override any `find_package` commands to use the CPM downloaded version.
This is equivalent to the `OVERRIDE_FIND_PACKAGE` FetchContent option, which has no effect in CPM.
To disable this behaviour set the `CPM_DONT_UPDATE_MODULE_PATH` option.
This will not work for `find_package(CONFIG)` in CMake versions before 3.24.

### CPM_USE_NAMED_CACHE_DIRECTORIES

If set, CPM use additional directory level in cache to improve readability of packages names in IDEs like CLion. It changes cache structure, so all dependencies are downloaded again. There is no problem to mix both structures in one cache directory but then there may be 2 copies of some dependencies.
This can also be set as an environmental variable.

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

## Private repositories and CI

When using CPM.cmake with private repositories, there may be a need to provide an [access token](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token) to be able to clone other projects. Instead of providing the token in CMake, we recommend to provide the regular URL and use [git-config](https://git-scm.com/docs/git-config) to rewrite the URLs to include the token.

As an example, you could include one of the following in your CI script.

```bash
# Github
git config --global url."https://${USERNAME}:${TOKEN}@github.com".insteadOf "https://github.com"
```

```bash
# GitLab
git config --global url."https://gitlab-ci-token:${CI_JOB_TOKEN}@gitlab.com".insteadOf "https://gitlab.com"
```

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
  <tr>
    <td>
      <a href="https://git.io/liblava">
        <p align="center">
          <img src="https://github.com/liblava.png" alt="liblava" width="100pt" />
        </p>
        <p align="center"><b>liblava - Modern Vulkan library</b></p>
      </a>
    </td>
    <td>
      <a href="https://github.com/variar/klogg">
        <p align="center">
          <img src="https://github.com/variar/klogg/blob/master/src/app/images/hicolor/scalable/klogg.svg" alt="klogg" width="100pt" />
        </p>
        <p align="center"><b>klogg - fast advanced log explorer</b></p>
      </a>
    </td>
    <td>
      <a href="https://github.com/MethanePowered/MethaneKit">
        <p align="center">
          <img src="https://github.com/MethanePowered/MethaneKit/raw/master/Docs/Images/Logo/MethaneLogoSmall.png" alt="MethaneKit" width="100pt" />
        </p>
        <p align="center"><b>Methane Kit - modern 3D graphics rendering framework</b></p>
      </a>
    </td>
  </tr>
  <tr>
    <td>
      <a href="https://github.com/jhasse/jngl">
        <p align="center">
          <img src="https://github.com/jhasse/jngl/raw/master/doc/jngl-logo.svg" alt="JNGL" width="100pt" />
        </p>
        <p align="center"><b>JNGL - easy to use cross-platform 2D game library</b></p>
      </a>
    </td>
    <td>
      <a href="https://github.com/sillydan1/aaltitoad">
        <p align="center">
          <img src="https://github.com/sillydan1/aaltitoad/raw/v1.1.0/.github/resources/logo/toad_only.svg" alt="aaltitoad" width="100pt" />
        </p>
        <p align="center"><b>AALTITOAD - verifier and simulator for Tick Tock Automata</b></p>
      </a>
    </td>
    <td>
      <a href="https://github.com/ZIMO-Elektronik">
        <p align="center">
          <img src="https://avatars.githubusercontent.com/u/117935012?s=400&u=9a871a46dd13437f0adcae166e9efbe518ff0b99&v=4" alt="ZIMO-Elektronik" width="100pt" />
        </p>
        <p align="center"><b>ZIMO-Elektronik</b></p>
      </a>
    </td>
  </tr>
  <tr>
    <td>
      <a href="https://github.com/ada-url/ada">
        <p align="center">
          <img src="https://avatars.githubusercontent.com/u/120840559?s=200&v=4" alt="ada" width="100pt" />
        </p>
        <p align="center"><b>ada - WHATWG-compliant and fast URL parser written in modern C++</b></p>
      </a>
    </td>
    <td>
      <a href="https://github.com/exaloop/codon">
        <p align="center">
          <img src="https://github.com/exaloop/codon/blob/develop/docs/img/logo.png?raw=true" alt="codon" width="100pt" />
        </p>
        <p align="center"><b>codon - A high-performance, zero-overhead, extensible Python compiler using LLVM</b></p>
      </a>
    </td>
    <td>
      <a href="https://github.com/RoaringBitmap/CRoaring">
        <p align="center">
          <img src="https://avatars.githubusercontent.com/u/16548876?s=200&v=4" alt="CRoaring" width="100pt" />
        </p>
        <p align="center"><b>CRoaring - Roaring bitmaps in C (and C++), with SIMD (AVX2, AVX-512 and NEON) optimizations: used by Apache Doris, ClickHouse, and StarRocks</b></p>
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

### [Range-v3](https://github.com/ericniebler/range-v3)

```Cmake
CPMAddPackage("gh:ericniebler/range-v3#0.12.0")
```

### [Yaml-cpp](https://github.com/jbeder/yaml-cpp)

```CMake
# as the tag is in an unusual format, we need to explicitly specify the version
CPMAddPackage("gh:jbeder/yaml-cpp#yaml-cpp-0.6.3@0.6.3")
```

### [nlohmann/json](https://github.com/nlohmann/json)

```cmake
CPMAddPackage("gh:nlohmann/json@3.9.1"
  OPTIONS "JSON_BuildTests OFF"
)
```

### [Boost](https://github.com/boostorg/boost)

Boost is a large project and will take a while to download. Using
`CPM_SOURCE_CACHE` is strongly recommended. Cloning moves much more
data than a source archive, so this sample will use a compressed
source archive (tar.xz) release from Boost's github page.

```CMake
# boost is a huge project and directly downloading the 'alternate release'
# from github is much faster than recursively cloning the repo.
CPMAddPackage(
  NAME Boost
  VERSION 1.84.0
  URL https://github.com/boostorg/boost/releases/download/boost-1.84.0/boost-1.84.0.tar.xz
  URL_HASH SHA256=2e64e5d79a738d0fa6fb546c6e5c2bd28f88d268a2a080546f74e5ff98f29d0e
  OPTIONS "BOOST_ENABLE_CMAKE ON"
)
```

For a working example of using CPM to download and configure the Boost C++ Libraries see [here](examples/boost).

### [cxxopts](https://github.com/jarro2783/cxxopts)

```cmake
# the install option has to be explicitly set to allow installation
CPMAddPackage(
  URI "gh:jarro2783/cxxopts@2.2.1"
  OPTIONS "CXXOPTS_BUILD_EXAMPLES NO" "CXXOPTS_BUILD_TESTS NO" "CXXOPTS_ENABLE_INSTALL YES"
)
```

### [google/benchmark](https://github.com/google/benchmark)

```cmake
CPMAddPackage(
  URI "gh:google/benchmark@1.5.2"
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

## Source Archives from GitHub

Using a compressed source archive is usually much faster than a shallow
clone. Optionally, you can verify the integrity using
[SHA256](https://en.wikipedia.org/wiki/SHA-2) or similar. Setting the hash is useful to ensure a
specific source is imported, especially since tags, branches, and
archives can change.

Let's look at adding [spdlog](https://github.com/gabime/spdlog) to a project:

```cmake
CPMAddPackage(
  NAME     spdlog
  URL      https://github.com/gabime/spdlog/archive/refs/tags/v1.12.0.zip
  URL_HASH SHA256=6174bf8885287422a6c6a0312eb8a30e8d22bcfcee7c48a6d02d1835d7769232
)
```

URL_HASH is optional, but it's a good idea for releases.


### Identifying the URL

Information for determining the URL is found
[here](https://docs.github.com/en/repositories/working-with-files/using-files/downloading-source-code-archives#source-code-archive-urls).


#### Release

Not every software package provides releases, but for those that do,
they can be found on the release page of the project. In a browser,
the URL of the specific release is determined in a browser is
determined by right clicking and selecting `Copy link address` (or
similar) for the desired release. This is the value you will use in
the URL section.

This is the URL for spdlog release 1.13.0 in zip format:
`https://github.com/gabime/spdlog/archive/refs/tags/v1.13.0.zip`


#### Branch

The URL for branches is non-obvious from a browser. But it's still fairly easy to figure it out. The format is as follows:

`https://github.com/<user>/<name>/archive/refs/heads/<branch-name>.<archive-type>`

Archive type can be one of `tar.gz` or `zip`.

The URL for branch `v2.x` of spdlog is:
`https://github.com/gabime/spdlog/archive/refs/heads/v2.x.tar.gz`


#### Tag

Tags are similar, but with this format:

`https://github.com/<user>/<name>/archive/refs/tags/<tag-name>.<archive-type>`

Tag `v1.8.5` of spdlog is this:

`https://github.com/gabime/spdlog/archive/refs/tags/v1.8.5.tar.gz`

Exactly like the release.


#### Commit

If a specific commit contains the code you need, it's defined as follows:

`https://github.com/<user>/<name>/archive/<commit-hash>.<archive-type>`

Example:
`https://github.com/gabime/spdlog/archive/c1569a3d293a6b511ecb9c18b2298826c9578d9f.tar.gz`


### Determining the Hash

The following snippet illustrates determining the SHA256 hash on a linux machine using `wget` and `sha256sum`:
```bash
wget https://github.com/gabime/spdlog/archive/refs/tags/v1.13.0.zip -O - | sha256sum
```
