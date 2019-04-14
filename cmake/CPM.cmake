cmake_minimum_required(VERSION 3.14 FATAL_ERROR)

if(CPM_DIRECTORY)
  if(NOT ${CPM_DIRECTORY} MATCHES ${CMAKE_CURRENT_LIST_DIR})
    return()
  endif()
endif()

option(CPM_LOCAL_PACKAGES_ONLY "Use only locally installed packages" OFF)
option(CPM_REMOTE_PACKAGES_ONLY "Always download packages" OFF)

set(CPM_DIRECTORY ${CMAKE_CURRENT_LIST_DIR} CACHE INTERNAL "")
set(CPM_PACKAGES "" CACHE INTERNAL "")

include(FetchContent)
include(CMakeParseArguments)

function(CPMRegisterPackage PACKAGE VERSION)
  LIST(APPEND CPM_PACKAGES ${CPM_ARGS_NAME})
  set(CPM_PACKAGES ${CPM_PACKAGES} CACHE INTERNAL "")
  set(PACKAGE_VERSION_VARIABLE "CPM_PACKAGE_${PACKAGE}_VERSION")
  set(${PACKAGE_VERSION_VARIABLE} ${VERSION} CACHE INTERNAL "")
endfunction()

function(CPMGetPreviousPackageVersion PACKAGE)
  set(PACKAGE_VERSION_VARIABLE "CPM_PACKAGE_${PACKAGE}_VERSION")
  set(CPM_PREVIOUS_PACKAGE_VERSION "${${PACKAGE_VERSION_VARIABLE}}" PARENT_SCOPE)
endfunction()

function(CPMAddPackage)
    
  set(oneValueArgs
    NAME
    VERSION
    GIT_TAG
  )

  set(multiValueArgs
    OPTIONS
  )

  cmake_parse_arguments(CPM_ARGS "" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

  if (NOT CPM_ARGS_GIT_TAG)
    set(CPM_ARGS_GIT_TAG v${CPM_ARGS_VERSION})
  endif()

  if (${CPM_ARGS_NAME} IN_LIST CPM_PACKAGES)
    CPMGetPreviousPackageVersion(${CPM_ARGS_NAME})
    message(STATUS "CPM: SKIP ${CPM_ARGS_NAME}@${CPM_ARGS_GIT_TAG}: already addded package ${CPM_ARGS_NAME}@${CPM_PREVIOUS_PACKAGE_VERSION}")
    return()
  endif()

  CPMRegisterPackage(${CPM_ARGS_NAME} ${CPM_ARGS_GIT_TAG})

  if (CPM_ARGS_OPTIONS)
    foreach(OPTION ${CPM_ARGS_OPTIONS})
      string(REGEX MATCH "^[^ ]+" OPTION_KEY ${OPTION})
      string(LENGTH ${OPTION_KEY} OPTION_KEY_LENGTH)
      math(EXPR OPTION_KEY_LENGTH "${OPTION_KEY_LENGTH}+1")
      string(SUBSTRING ${OPTION} "${OPTION_KEY_LENGTH}" "-1" OPTION_VALUE)
      set(${OPTION_KEY} ${OPTION_VALUE} CACHE INTERNAL "")
    endforeach()
  endif()

  if (NOT ${CPM_REMOTE_PACKAGES_ONLY})
    find_package(${CPM_ARGS_NAME} ${CPM_ARGS_VERSION} QUIET)
    set(CPM_PACKAGE_FOUND ${CPM_ARGS_NAME}_FOUND)

    if(${CPM_PACKAGE_FOUND})
      message(STATUS "CPM: ADD local package ${CPM_ARGS_NAME}@${CPM_ARGS_VERSION}")
      set_target_properties(${CPM_ARGS_NAME} 
        PROPERTIES
          IMPORTED_GLOBAL True
      )
      return()
    endif()
  endif()

  if (NOT ${CPM_LOCAL_PACKAGES_ONLY})

    message(STATUS "CPM: ADD remote package ${CPM_ARGS_NAME}@${CPM_ARGS_GIT_TAG}")

    set(CPM_PACKAGE_CONTENT ${CPM_ARGS_NAME}_CONTENT)

    FetchContent_Declare(
      ${CPM_PACKAGE_CONTENT}
      GIT_TAG ${CPM_ARGS_GIT_TAG}
      ${CPM_ARGS_UNPARSED_ARGUMENTS}
    )
    
    FetchContent_MakeAvailable(${CPM_PACKAGE_CONTENT})
  else()
    MESSAGE(ERROR "CPM could not find the local package ${CPM_ARGS_NAME}@${CPM_ARGS_VERSION}")
  endif()

endfunction()
