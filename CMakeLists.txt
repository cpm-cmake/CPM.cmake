cmake_minimum_required(VERSION 3.14 FATAL_ERROR)

find_package(Git REQUIRED QUIET)

project(CPM LANGUAGES NONE)

if(GIT_EXECUTABLE)
  # Generate a git-describe version string from Git repository tags
  execute_process(
    COMMAND ${GIT_EXECUTABLE} tag --points-at HEAD
    WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
    OUTPUT_VARIABLE CURRENT_CPM_VERSION
    RESULT_VARIABLE GIT_DESCRIBE_ERROR_CODE
    OUTPUT_STRIP_TRAILING_WHITESPACE
  )
  if(NOT GIT_DESCRIBE_ERROR_CODE AND NOT CURRENT_CPM_VERSION STREQUAL "")
    string(SUBSTRING ${CURRENT_CPM_VERSION} 1 -1 CURRENT_CPM_VERSION)
  else()
    set(CURRENT_CPM_VERSION 1.0.0-development-version)
  endif()
endif()

include("${CMAKE_CURRENT_SOURCE_DIR}/cmake/CPM.cmake")
