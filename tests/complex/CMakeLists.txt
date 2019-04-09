cmake_minimum_required(VERSION 3.5 FATAL_ERROR)

project(CPMTest)

include(${CMAKE_CURRENT_SOURCE_DIR}/../../cmake/CPM.cmake)

CPMAddPackage(
  NAME LHC
  GIT_REPOSITORY https://github.com/TheLartians/LHC.git
  VERSION 0.3
)

CPMAddPackage(
  NAME LarsEvent
  GIT_REPOSITORY https://github.com/TheLartians/Event.git
  VERSION 1.0
  GIT_TAG master
)

# Add project that depends on previous project
CPMAddPackage(
  NAME LarsParser
  GIT_REPOSITORY https://github.com/TheLartians/Parser.git
  VERSION 1.4
)

# add project twice (will be ignored)
CPMAddPackage(
  NAME LHC
  GIT_REPOSITORY https://github.com/TheLartians/LHC.git
  VERSION 0.1
)

# add executable
set (CMAKE_CXX_STANDARD 17)
add_executable(cpm-test test.cpp)
target_link_libraries(cpm-test LHC LarsEvent LarsParser)

# tests
enable_testing()
add_test(cpm-test cpm-test)
