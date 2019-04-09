[![Build Status](https://travis-ci.com/TheLartians/CPM.svg?branch=master)](https://travis-ci.com/TheLartians/CPM)

# CPM

CPM is a very simple package manager written in Cmake based on the amazing [DownloadProject](https://github.com/Crascit/DownloadProject) script. It is extremely easy to use and drastically simplifies the inclusion of other Cmake-based projects from github.

# Usage

To add a new dependency to your project simply add the Projects target name, the git URL and the version. If the git tag for this version does not match the pattern `v$VERSION`, then the exact branch or tag can be specified with the `GIT_TAG` argument.

```cmake
cmake_minimum_required(VERSION 3.5 FATAL_ERROR)

project(MyParser)

# add dependencies
include(${CMAKE_CURRENT_SOURCE_DIR}/cmake/CPM.cmake)

CPMAddPackage(
  NAME LarsParser
  VERSION 1.2
  GIT_REPOSITORY https://github.com/TheLartians/Parser.git
  GIT_TAG master # optional
)

# add executable
set (CMAKE_CXX_STANDARD 17)
add_executable(my-parser my-parser.cpp)
target_link_libraries(cpm-test LarsParser)
```

# Installation

To add CPM to your current project, copy the scripts in the `cmake` directory into you current project project. The command below will perform this automatically.

```bash
wget -qO- https://github.com/TheLartians/CPM/releases/download/v0.1/cmake.zip | bsdtar -xvf-
```

# Limitations

- First version used: in diamond dependency graphs (e.g. `A` depends on `C`(v1.1) and `A` depends on `B` depends on `C`(v1.2)) the first added dependency will be used (in this case `C`@1.1).
- No possibility not automatically update dependencies. To update a dependency, version numbers or git tags in the cmake scripts must be adapted manually.
