cmake_minimum_required(VERSION 3.5 FATAL_ERROR)

project(CPMTest)

# add dependencies
include(../../cmake/CPM.cmake)

CPMAddPackage(
  NAME LarsParser
  GIT_REPOSITORY https://github.com/TheLartians/Parser.git
  VERSION 1.7
)

# add executable
add_executable(cpm-test-simple main.cpp)
set_target_properties(cpm-test-simple PROPERTIES CXX_STANDARD 17)
target_link_libraries(cpm-test-simple LarsParser)

# tests
enable_testing()
add_test(cpm-test-simple cpm-test-simple)
