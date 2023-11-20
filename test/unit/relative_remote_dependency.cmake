if(NOT POLICY CMP0150)
  return()
endif()

cmake_minimum_required(VERSION 3.27 FATAL_ERROR)

include(${CPM_PATH}/testing.cmake)
include(CMakePackageConfigHelpers)

set(CPM_SOURCE_CACHE_DIR "${CMAKE_CURRENT_BINARY_DIR}/CPM")
set(TEST_BUILD_DIR ${CMAKE_CURRENT_BINARY_DIR}/relative_remote_dependency)

message(STATUS "clearing CPM cache")
file(REMOVE_RECURSE ${CPM_SOURCE_CACHE_DIR})
assert_not_exists("${CPM_SOURCE_CACHE_DIR}")

file(REMOVE_RECURSE ${TEST_BUILD_DIR})

configure_package_config_file(
  "${CMAKE_CURRENT_LIST_DIR}/relative_remote_dependency/CMakeLists.txt.in"
  "${CMAKE_CURRENT_LIST_DIR}/relative_remote_dependency/CMakeLists.txt"
  INSTALL_DESTINATION ${CMAKE_CURRENT_BINARY_DIR}/junk
)

execute_process(
  COMMAND ${CMAKE_COMMAND} "-S${CMAKE_CURRENT_LIST_DIR}/relative_remote_dependency"
          "-B${TEST_BUILD_DIR}" "-DCPM_SOURCE_CACHE=${CPM_SOURCE_CACHE_DIR}" RESULT_VARIABLE ret
)

assert_equal(${ret} "0")
