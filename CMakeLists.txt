cmake_minimum_required(VERSION 3.14 FATAL_ERROR)

project(
  CPM.cmake
  VERSION 0.37.0
  LANGUAGES NONE
)

include(CMakePackageConfigHelpers)
configure_package_config_file(
  "${CMAKE_CURRENT_SOURCE_DIR}/cmake/CPM.cmakeConfig.cmake.in"
  "${CMAKE_CURRENT_BINARY_DIR}/CPM.cmakeConfig.cmake"
  INSTALL_DESTINATION "${CMAKE_INSTALL_LIBDIR}/cmake/CPM.cmake"
)
write_basic_package_version_file(
  "${CMAKE_CURRENT_BINARY_DIR}/CPM.cmakeConfigVersion.cmake" COMPATIBILITY SameMinorVersion
                                                                     ARCH_INDEPENDENT
)

# For consumer using FetchContent
if(NOT ${CMAKE_PROJECT_NAME} STREQUAL ${PROJECT_NAME})
  # Check if the user download the repo with git and not in an official release
  if(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/.git" AND IS_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/.git")
    find_package(Git REQUIRED QUIET)
    # Generate a git-describe version string from Git repository tags.
    execute_process(
      COMMAND ${GIT_EXECUTABLE} tag --points-at HEAD
      WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
      OUTPUT_VARIABLE CPM_TAG
      RESULT_VARIABLE GIT_DESCRIBE_ERROR_CODE
      OUTPUT_STRIP_TRAILING_WHITESPACE
    )
    if(NOT GIT_DESCRIBE_ERROR_CODE AND NOT CPM_TAG STREQUAL "")
      set(CPM_RELEASE TRUE)
    else()
      set(CPM_RELEASE FALSE)
    endif()
  else()
    set(CPM_RELEASE TRUE)
  endif()
endif()

# Trick to use the find_package
configure_file("${CMAKE_CURRENT_SOURCE_DIR}/cmake/CPM.cmake" "${CMAKE_CURRENT_BINARY_DIR}/CPM.cmake" COPYONLY)
# Unset in case CPM has been used to install itself
unset(CPM.cmake_FOUND)
set(CPM.cmake_DIR "${CMAKE_CURRENT_BINARY_DIR}" CACHE INTERNAL "" FORCE)
find_package(CPM.cmake ${PROJECT_VERSION} REQUIRED CONFIG)

if(CMAKE_PROJECT_NAME STREQUAL PROJECT_NAME)
  # Without it : Unable to determine default CMAKE_INSTALL_LIBDIR directory because no target
  # architecture is known.  Please enable at least one language before including GNUInstallDirs.
  enable_language(C)
  include(GNUInstallDirs)
  install(
    FILES "${CMAKE_CURRENT_BINARY_DIR}/CPM.cmakeConfig.cmake"
          "${CMAKE_CURRENT_BINARY_DIR}/CPM.cmakeConfigVersion.cmake"
          "${CMAKE_CURRENT_SOURCE_DIR}/cmake/CPM.cmake"
    DESTINATION "${CMAKE_INSTALL_LIBDIR}/cmake/CPM.cmake"
  )
endif()
