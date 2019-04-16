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

# adding LHC again will be ignored as the package has already been added
CPMAddPackage(
  NAME LHC
  GIT_REPOSITORY https://github.com/TheLartians/LHC.git
  VERSION 0.1
)

# language bindings
# uses git tag instead of version identifier
# depends on visitor library that depends on Event library and LHC (ignored as already added)
# configuration arguments passed via OPTIONS. these will all be set internally
set(GLUE_ENABLE_LUA ON)
CPMAddPackage(
  NAME Glue
  GIT_TAG 78af65625751ad15a42ca52b842863e85b5d2adc
  GIT_REPOSITORY https://github.com/TheLartians/Glue.git
  OPTIONS 
    "GLUE_ENABLE_LUA ON"
    "GLUE_BUILD_LUA ON"
)

# parser library 
# depends on LHC (ignored as already added)
CPMAddPackage(
  NAME LarsParser
  GIT_REPOSITORY https://github.com/TheLartians/Parser.git
  VERSION 1.8
  OPTIONS 
    "LARS_PARSER_BUILD_GLUE_EXTENSION ON"
)

# add executable
set (CMAKE_CXX_STANDARD 17)
add_executable(cpm-test-complex main.cpp)
target_link_libraries(cpm-test-complex LHC LarsParser Glue)

# tests
enable_testing()
add_test(cpm-test-complex cpm-test-complex)
