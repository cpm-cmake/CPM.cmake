cmake_minimum_required(VERSION 3.14 FATAL_ERROR)

if(CPM_DIRECTORY)
  if(NOT ${CPM_DIRECTORY} MATCHES ${CMAKE_CURRENT_LIST_DIR})
    return()
  endif()
endif()

set(CPM_DIRECTORY ${CMAKE_CURRENT_LIST_DIR} CACHE INTERNAL "")
set(CPM_PACKAGES "" CACHE INTERNAL "")

include(FetchContent)
include(CMakeParseArguments)

option(CPM_LOCAL_PACKAGES_ONLY "Use only locally installed packages" OFF)
option(CPM_REMOTE_PACKAGES_ONLY "Always download packages" OFF)


function(CPMAddPackage)
    
  set(oneValueArgs
    NAME
    VERSION
    GIT_TAG
  )

  cmake_parse_arguments(CPM_ARGS QUIET "${oneValueArgs}" "" ${ARGN})

  if (NOT CPM_ARGS_GIT_TAG)
    set(CPM_ARGS_GIT_TAG v${CPM_ARGS_VERSION})
  endif()

  if (${CPM_ARGS_NAME} IN_LIST CPM_PACKAGES)
    message(STATUS "CPM: not adding ${CPM_ARGS_NAME}@${CPM_ARGS_GIT_TAG}: already addded package ${CPM_ARGS_NAME}")
    return()
  endif()

  LIST(APPEND CPM_PACKAGES ${CPM_ARGS_NAME})
  set(CPM_PACKAGES ${CPM_PACKAGES} CACHE INTERNAL "")

  if (NOT ${CPM_REMOTE_PACKAGES_ONLY})
    find_package(${CPM_ARGS_NAME} ${CPM_ARGS_VERSION} QUIET)
    set(CPM_PACKAGE_FOUND ${CPM_ARGS_NAME}_FOUND)
  
    if(${CPM_PACKAGE_FOUND})
      message(STATUS "CPM: using local package ${CPM_ARGS_NAME}@${CPM_ARGS_VERSION}")
      set_target_properties(${CPM_ARGS_NAME} 
        PROPERTIES
          IMPORTED_GLOBAL True
      )
      return()
    endif()
  endif()

  if (NOT ${CPM_LOCAL_PACKAGES_ONLY})

    message(STATUS "CPM: fetching package ${CPM_ARGS_NAME}@${CPM_ARGS_GIT_TAG}")

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
