cmake_minimum_required(VERSION 3.5 FATAL_ERROR)

project(CPMTest)

include(${CMAKE_CURRENT_SOURCE_DIR}/../../cmake/CPM.cmake)

# ignore locally installed projects for reproducable builds
set(CPM_REMOTE_PACKAGES_ONLY ON CACHE INTERNAL "")

# util library
CPMAddPackage(
  NAME LHC
  GIT_REPOSITORY https://github.com/TheLartians/LHC.git
  VERSION 0.7
)

# util library
# will be ignored as package has already been added
CPMAddPackage(
  NAME LHC
  GIT_REPOSITORY https://github.com/TheLartians/LHC.git
  VERSION 0.1
)

# language bindings
# depends on visitor library that depends on Event library and LHC (ignored as already added)
# configuration arguments passed via OPTIONS. these will all be set internally
set(GLUE_ENABLE_LUA ON)
CPMAddPackage(
  NAME Glue
  GIT_TAG 07bc2091166ba7a142a7194d1d108de8986efda1
  GIT_REPOSITORY https://github.com/TheLartians/Glue.git
  OPTIONS 
    "GLUE_ENABLE_LUA ON"
    "GLUE_BUILD_LUA ON"
)

# parser library 
# depends on LHC 
CPMAddPackage(
  NAME LarsParser
  GIT_REPOSITORY https://github.com/TheLartians/Parser.git
  VERSION 1.7
  OPTIONS 
    "BUILD_LARS_PARSER_GLUE_EXTENSION ON"
)

# add executable
set (CMAKE_CXX_STANDARD 17)
add_executable(cpm-test test.cpp)
target_link_libraries(cpm-test LHC LarsParser Glue)

# tests
enable_testing()
add_test(cpm-test cpm-test)
