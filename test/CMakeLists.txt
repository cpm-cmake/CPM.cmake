cmake_minimum_required(VERSION 3.5 FATAL_ERROR)

project(CPMTest)

include(${CMAKE_CURRENT_SOURCE_DIR}/../cmake/CPM.cmake)

CPMAddPackage(
  NAME LHC
  GIT_REPOSITORY https://github.com/TheLartians/LHC.git
  VERSION 0.3
)

CPMAddPackage(
  NAME LarsEvent
  GIT_REPOSITORY https://github.com/TheLartians/Event.git
  VERSION 1.0
)

# Add project that depends on previous project
CPMAddPackage(
  NAME LarsParser
  GIT_REPOSITORY https://github.com/TheLartians/Parser.git
  VERSION 1.2
)

# add project twice
CPMAddPackage(
  NAME LHC
  GIT_REPOSITORY https://github.com/TheLartians/LHC.git
  VERSION 0.3
)
