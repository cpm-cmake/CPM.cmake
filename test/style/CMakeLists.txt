cmake_minimum_required(VERSION 3.14 FATAL_ERROR)

project(CPMStyleCheck)

include(${CMAKE_CURRENT_LIST_DIR}/../../cmake/CPM.cmake)

CPMAddPackage(
  NAME Format.cmake
  VERSION 1.7.3
  GITHUB_REPOSITORY TheLartians/Format.cmake
  OPTIONS "CMAKE_FORMAT_EXCLUDE integration/templates"
)
