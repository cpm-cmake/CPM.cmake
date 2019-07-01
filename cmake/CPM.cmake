# TheLartians/CPM - A simple Git dependency manager
# =================================================
# See https://github.com/TheLartians/CPM for usage and update instructions.
#
# MIT License
# ----------- 
#[[
  Copyright (c) 2019 Lars Melchior

  Permission is hereby granted, free of charge, to any person obtaining a copy
  of this software and associated documentation files (the "Software"), to deal
  in the Software without restriction, including without limitation the rights
  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
  copies of the Software, and to permit persons to whom the Software is
  furnished to do so, subject to the following conditions:

  The above copyright notice and this permission notice shall be included in all
  copies or substantial portions of the Software.

  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
  SOFTWARE.
]]

cmake_minimum_required(VERSION 3.14 FATAL_ERROR)

set(CURRENT_CPM_VERSION 0.12) 

if(CPM_DIRECTORY)
  if(NOT ${CPM_DIRECTORY} MATCHES ${CMAKE_CURRENT_LIST_DIR})
    if (${CPM_VERSION} VERSION_LESS ${CURRENT_CPM_VERSION})
      CPM_HANDLE_OLD_VERSION(${CURRENT_CPM_VERSION})  
    endif()
    return()
  endif()
endif()

set(CPM_VERSION ${CURRENT_CPM_VERSION} CACHE INTERNAL "")
set(CPM_DIRECTORY ${CMAKE_CURRENT_LIST_DIR} CACHE INTERNAL "")
set(CPM_PACKAGES "" CACHE INTERNAL "")
set(CPM_DRY_RUN OFF CACHE INTERNAL "Don't download or configure dependencies (for testing)")

option(CPM_USE_LOCAL_PACKAGES "Use locally installed packages (find_package)" OFF)
option(CPM_LOCAL_PACKAGES_ONLY "Use only locally installed packages" OFF)


include(FetchContent)
include(CMakeParseArguments)

# Initialize logging prefix
if(NOT CPM_INDENT)
  set(CPM_INDENT "CPM:")
endif()

# The main workhorse of CPM
function(CPMAddPackage)

  set(oneValueArgs
    NAME
    VERSION
    GIT_TAG
    DOWNLOAD_ONLY
    GITHUB_REPOSITORY
    GITLAB_REPOSITORY
  )

  set(multiValueArgs
    OPTIONS
  )

  cmake_parse_arguments(CPM_ARGS "" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

  if(${CPM_USE_LOCAL_PACKAGES} OR ${CPM_LOCAL_PACKAGES_ONLY}) 
    find_package(${CPM_ARGS_NAME} ${CPM_ARGS_VERSION} QUIET)

    if(${CPM_PACKAGE_FOUND})
      message(STATUS "CPM: adding local package ${CPM_ARGS_NAME}@${CPM_ARGS_VERSION}")
      set_target_properties(${CPM_ARGS_NAME} 
        PROPERTIES
          IMPORTED_GLOBAL True
      )
      return()
    endif()

    if(${CPM_LOCAL_PACKAGES_ONLY}) 
      message(SEND_ERROR "CPM: ${CPM_ARGS_NAME} not found via find_package(${CPM_ARGS_NAME} ${CPM_ARGS_VERSION})")
    endif()
  endif()

  if (NOT DEFINED CPM_ARGS_VERSION)
    if (DEFINED CPM_ARGS_GIT_TAG) 
      CPM_GET_VERSION_FROM_GIT_TAG("${CPM_ARGS_GIT_TAG}" CPM_ARGS_VERSION)
    endif()
    if (NOT DEFINED CPM_ARGS_VERSION) 
      set(CPM_ARGS_VERSION 0)
    endif()
  endif()

  if (NOT DEFINED CPM_ARGS_GIT_TAG)
    set(CPM_ARGS_GIT_TAG v${CPM_ARGS_VERSION})
  endif()

  list(APPEND CPM_ARGS_UNPARSED_ARGUMENTS GIT_TAG ${CPM_ARGS_GIT_TAG})

  if(CPM_ARGS_DOWNLOAD_ONLY)
    set(DOWNLOAD_ONLY ${CPM_ARGS_DOWNLOAD_ONLY})
  else()
    set(DOWNLOAD_ONLY NO)
  endif()

  if (CPM_ARGS_GITHUB_REPOSITORY)
    list(APPEND CPM_ARGS_UNPARSED_ARGUMENTS GIT_REPOSITORY "https://github.com/${CPM_ARGS_GITHUB_REPOSITORY}.git")
  endif()

  if (CPM_ARGS_GITLAB_REPOSITORY)
    list(APPEND CPM_ARGS_UNPARSED_ARGUMENTS GIT_REPOSITORY "https://gitlab.com/${CPM_ARGS_GITLAB_REPOSITORY}.git")
  endif()

  if (${CPM_ARGS_NAME} IN_LIST CPM_PACKAGES)
    CPM_GET_PACKAGE_VERSION(${CPM_ARGS_NAME} CPM_PACKAGE_VERSION)
    if(${CPM_PACKAGE_VERSION} VERSION_LESS ${CPM_ARGS_VERSION})
      message(WARNING "${CPM_INDENT} requires a newer version of ${CPM_ARGS_NAME} (${CPM_ARGS_VERSION}) than currently included (${CPM_PACKAGE_VERSION}).")
    endif()
    if (CPM_ARGS_OPTIONS)
      foreach(OPTION ${CPM_ARGS_OPTIONS})
        CPM_PARSE_OPTION(${OPTION})
        if(NOT "${${OPTION_KEY}}" STREQUAL ${OPTION_VALUE})
          message(WARNING "${CPM_INDENT} ignoring package option for ${CPM_ARGS_NAME}: ${OPTION_KEY} = ${OPTION_VALUE} (${${OPTION_KEY}})")
        endif()
      endforeach()
    endif()
    CPM_FETCH_PACKAGE(${CPM_ARGS_NAME} ${DOWNLOAD_ONLY})
    CPMGetProperties(${CPM_ARGS_NAME})
    SET(${CPM_ARGS_NAME}_SOURCE_DIR "${${CPM_ARGS_NAME}_SOURCE_DIR}" PARENT_SCOPE)
    SET(${CPM_ARGS_NAME}_BINARY_DIR "${${CPM_ARGS_NAME}_BINARY_DIR}" PARENT_SCOPE)  
    SET(${CPM_ARGS_NAME}_ADDED NO PARENT_SCOPE)  
    return()
  endif()

  CPMRegisterPackage(${CPM_ARGS_NAME} ${CPM_ARGS_VERSION})

  if (CPM_ARGS_OPTIONS)
    foreach(OPTION ${CPM_ARGS_OPTIONS})
      CPM_PARSE_OPTION(${OPTION})
      set(${OPTION_KEY} ${OPTION_VALUE} CACHE INTERNAL "")
    endforeach()
  endif()

  CPM_DECLARE_PACKAGE(${CPM_ARGS_NAME} ${CPM_ARGS_VERSION} ${CPM_ARGS_GIT_TAG} "${CPM_ARGS_UNPARSED_ARGUMENTS}")
  CPM_FETCH_PACKAGE(${CPM_ARGS_NAME} ${DOWNLOAD_ONLY})
  CPMGetProperties(${CPM_ARGS_NAME})
  SET(${CPM_ARGS_NAME}_SOURCE_DIR "${${CPM_ARGS_NAME}_SOURCE_DIR}" PARENT_SCOPE)
  SET(${CPM_ARGS_NAME}_BINARY_DIR "${${CPM_ARGS_NAME}_BINARY_DIR}" PARENT_SCOPE)
  SET(${CPM_ARGS_NAME}_ADDED YES PARENT_SCOPE)  
endfunction()

function (CPM_DECLARE_PACKAGE PACKAGE VERSION GIT_TAG)
  message(STATUS "${CPM_INDENT} adding package ${PACKAGE}@${VERSION} (${GIT_TAG})")

  if (${CPM_DRY_RUN}) 
    message(STATUS "${CPM_INDENT} package not declared (dry run)")
    return()
  endif()

  FetchContent_Declare(
    ${PACKAGE}
    ${ARGN}
  )
endfunction()

function (CPM_FETCH_PACKAGE PACKAGE DOWNLOAD_ONLY)  

  if (${CPM_DRY_RUN}) 
    message(STATUS "${CPM_INDENT} package ${PACKAGE} not fetched (dry run)")
    return()
  endif()

  set(CPM_OLD_INDENT "${CPM_INDENT}")
  set(CPM_INDENT "${CPM_INDENT} ${PACKAGE}:")
  if(${DOWNLOAD_ONLY})
    if(NOT "${PACKAGE}_POPULATED")
      FetchContent_Populate(${PACKAGE})
    endif()
  else()
    FetchContent_MakeAvailable(${PACKAGE})
  endif()
  set(CPM_INDENT "${CPM_OLD_INDENT}")
endfunction()

function (CPMGetProperties PACKAGE)
  if (${CPM_DRY_RUN}) 
    return()
  endif()
  FetchContent_GetProperties(${PACKAGE})
  string(TOLOWER ${PACKAGE} lpackage)
  SET(${PACKAGE}_SOURCE_DIR "${${lpackage}_SOURCE_DIR}" PARENT_SCOPE)
  SET(${PACKAGE}_BINARY_DIR "${${lpackage}_BINARY_DIR}" PARENT_SCOPE)
endfunction()

function(CPMRegisterPackage PACKAGE VERSION)
  list(APPEND CPM_PACKAGES ${PACKAGE})
  set(CPM_PACKAGES ${CPM_PACKAGES} CACHE INTERNAL "")
  set("CPM_PACKAGE_${PACKAGE}_VERSION" ${VERSION} CACHE INTERNAL "")
endfunction()

function(CPM_GET_PACKAGE_VERSION PACKAGE OUTPUT)
  set(${OUTPUT} "${CPM_PACKAGE_${PACKAGE}_VERSION}" PARENT_SCOPE)
endfunction()

function(CPM_PARSE_OPTION OPTION)
  string(REGEX MATCH "^[^ ]+" OPTION_KEY ${OPTION})
  string(LENGTH ${OPTION_KEY} OPTION_KEY_LENGTH)
  math(EXPR OPTION_KEY_LENGTH "${OPTION_KEY_LENGTH}+1")
  string(SUBSTRING ${OPTION} "${OPTION_KEY_LENGTH}" "-1" OPTION_VALUE)
  set(OPTION_KEY "${OPTION_KEY}" PARENT_SCOPE)
  set(OPTION_VALUE "${OPTION_VALUE}" PARENT_SCOPE)
endfunction()

function(CPM_GET_VERSION_FROM_GIT_TAG GIT_TAG RESULT)
  string(REGEX MATCH "v?([0123456789.]*).*" _ ${GIT_TAG})
  SET(${RESULT} ${CMAKE_MATCH_1} PARENT_SCOPE)
endfunction()

function (CPM_HANDLE_OLD_VERSION NEW_CPM_VERSION)
  
  message(AUTHOR_WARNING "${CPM_INDENT} \
A dependency is using a more recent CPM (${NEW_CPM_VERSION}) than the current project (${CPM_VERSION}). \
It is recommended to upgrade CPM to the most recent version. \
See https://github.com/TheLartians/CPM for more information."
  )

endfunction()
