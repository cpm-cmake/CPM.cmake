[![Build Status](https://travis-ci.com/TheLartians/CPM.svg?branch=master)](https://travis-ci.com/TheLartians/CPM)

# CPM

CPM is a very simple package manager written in Cmake. It is extremely easy to use and drastically simplifies the inclusion of other Cmake-based projects from github.

# Usage

To add a new dependency to your project simply add the Projects target name, the git URL and a valid git tag or branch. 

```cmake
cmake_minimum_required(VERSION 3.5 FATAL_ERROR)

project(MyParser)

# add dependencies
include(${CMAKE_CURRENT_SOURCE_DIR}/cmake/CPM.cmake)

CPMAddPackage(
  NAME LarsParser
  GIT_REPOSITORY https://github.com/TheLartians/Parser.git
  VERSION 1.2
)

# add executable
set (CMAKE_CXX_STANDARD 17)
add_executable(my-parser my-parser.cpp)
target_link_libraries(cpm-test LarsParser)
```
