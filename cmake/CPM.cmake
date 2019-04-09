set(_CPM_Dir "${CMAKE_CURRENT_LIST_DIR}")

include(CMakeParseArguments)
include(${_CPM_Dir}/DownloadProject.cmake)

function(CPMHasPackage) 
  
endfunction()

function(CPMAddPackage)
  set(options QUIET)
    
  set(oneValueArgs
    NAME
    GIT_REPOSITORY
    VERSION
    GIT_TAG
    BINARY_DIR
  )

  set(multiValueArgs "")

  cmake_parse_arguments(CPM_ARGS "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

  if (NOT CPM_PACKAGES)
    set(CPM_PACKAGES "")
  endif()

  if (NOT CPM_ARGS_BINARY_DIR)
    set(CPM_ARGS_BINARY_DIR ${CMAKE_BINARY_DIR}/CPM-projects/${CPM_ARGS_NAME})
  endif()

  if (NOT CPM_PROJECT_DIR)
    set(CPM_PROJECT_DIR "${CPM_ARGS_BINARY_DIR}")
  endif()

  if (NOT CPM_ARGS_GIT_TAG)
    set(CPM_ARGS_GIT_TAG v${CPM_ARGS_VERSION})
  endif()

  SET(CPM_TARGET_CMAKE_FILE "${CPM_PROJECT_DIR}")

  if (${CPM_ARGS_NAME} IN_LIST CPM_PACKAGES)
    message(STATUS "CPM: package ${CPM_ARGS_NAME} already added")
  else()
    message(STATUS "CPM: adding package ${CPM_ARGS_NAME}@${CPM_ARGS_VERSION}")
    # update package data
    LIST(APPEND CPM_PACKAGES ${CPM_ARGS_NAME})
    # save package data
    set(CPM_PACKAGES "${CPM_PACKAGES}" CACHE INTERNAL "CPM Packages")

    configure_file(
      "${_CPM_Dir}/CPMProject.CMakeLists.cmake.in"
      "${CPM_TARGET_CMAKE_FILE}/CMakeLists.txt"
      @ONLY
    )
  endif()

  if (NOT TARGET ${CPM_ARGS_NAME})
    add_subdirectory(${CPM_TARGET_CMAKE_FILE} ${CPM_ARGS_BINARY_DIR})
  endif()

endfunction()
