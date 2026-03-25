cmake_minimum_required(VERSION 3.14 FATAL_ERROR)

if(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/.git/")
  find_package(Git REQUIRED)
  execute_process(
    COMMAND "${GIT_EXECUTABLE}" describe --tags --long
    WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}"
    OUTPUT_VARIABLE DESCRIBE_NAME COMMAND_ERROR_IS_FATAL ANY
  )
  string(STRIP ${DESCRIBE_NAME} DESCRIBE_NAME)
  string(REGEX MATCH "v[0-9]*.[0-9]*.[0-9]*\-0\-[a-zA-Z0-9]*" DESCRIBE_NAME ${DESCRIBE_NAME})
  if(DESCRIBE_NAME STREQUAL "")
    set(CPM_DEVELOPMENT "-development-version")
  endif()
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
