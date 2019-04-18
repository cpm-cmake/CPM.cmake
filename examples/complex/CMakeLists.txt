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

# will be ignored as newer version already added
CPMAddPackage(
  NAME LHC
  GIT_REPOSITORY https://github.com/TheLartians/LHC.git
  VERSION 0.2
)

# language bindings
# uses git tag instead of version identifier
# depends on visitor library that depends on Event library and LHC
# CMake configuration arguments passed via OPTIONS
CPMAddPackage(
  NAME Glue
  GIT_TAG 78af65625751ad15a42ca52b842863e85b5d2adc
  GIT_REPOSITORY https://github.com/TheLartians/Glue.git
  VERSION 0.5.1
  OPTIONS 
    "GLUE_ENABLE_LUA ON"
    "GLUE_BUILD_LUA ON"
)

# parser library 
# depends on LHC and Glue
CPMAddPackage(
  NAME LarsParser
  GIT_REPOSITORY https://github.com/TheLartians/Parser.git
  VERSION 1.8
  OPTIONS 
    "LARS_PARSER_BUILD_GLUE_EXTENSION ON"
)

# add executable
add_executable(cpm-test-complex main.cpp)
set_target_properties(cpm-test-complex PROPERTIES CXX_STANDARD 17)
target_link_libraries(cpm-test-complex LHC LarsParser Glue)

# tests
enable_testing()
add_test(cpm-test-complex cpm-test-complex)
