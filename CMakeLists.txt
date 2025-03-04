cmake_minimum_required(VERSION 3.14 FATAL_ERROR)

if(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/.git/")
  find_package(Git REQUIRED)
  execute_process(
    COMMAND "${GIT_EXECUTABLE}" describe --tags --match=?[0-9.]*
    WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}"
    OUTPUT_VARIABLE DESCRIBE_NAME COMMAND_ERROR_IS_FATAL ANY
  )
  set(CPM_DEVELOPMENT "-development-version")
else()
  file(STRINGS "${CMAKE_CURRENT_SOURCE_DIR}/.git_archival.txt" DESCRIBE_NAME
       REGEX "^describe-name:.*"
  )
endif()

string(REGEX MATCH "([0-9\\.]+)" EXTRACTED_CPM_VERSION "${DESCRIBE_NAME}")

project(
  CPM.cmake
  VERSION "${EXTRACTED_CPM_VERSION}"
  DESCRIPTION
    "CMake's missing package manager. A small CMake script for setup-free, cross-platform, reproducible dependency management."
  HOMEPAGE_URL "https://github.com/cpm-cmake/CPM.cmake"
  LANGUAGES NONE
)

include("${CMAKE_CURRENT_SOURCE_DIR}/cmake/CPM.cmake")
