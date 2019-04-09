cmake_minimum_required(VERSION 3.5 FATAL_ERROR)

project(CPMTest)

# add dependencies
include(${CMAKE_CURRENT_SOURCE_DIR}/../../cmake/CPM.cmake)

CPMAddPackage(
  NAME LarsParser
  GIT_REPOSITORY https://github.com/TheLartians/Parser.git
  VERSION 1.3
)

# add executable
set (CMAKE_CXX_STANDARD 17)
add_executable(cpm-test test.cpp)
target_link_libraries(cpm-test LarsParser)

# tests
enable_testing()
add_test(cpm-test cpm-test)
