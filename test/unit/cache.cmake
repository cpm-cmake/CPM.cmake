cmake_minimum_required(VERSION 3.14 FATAL_ERROR)

include(${CPM_PATH}/testing.cmake)
include(CMakePackageConfigHelpers)

set(CPM_SOURCE_CACHE_DIR "${CMAKE_CURRENT_BINARY_DIR}/CPM")
set(TEST_BUILD_DIR ${CMAKE_CURRENT_BINARY_DIR}/cache)

function(clear_cache)
  message(STATUS "clearing CPM cache")
  FILE(REMOVE_RECURSE ${CPM_SOURCE_CACHE_DIR})
  ASSERT_NOT_EXISTS("${CPM_SOURCE_CACHE_DIR}")
endfunction()

function(update_cmake_lists)
  configure_package_config_file(
    "${CMAKE_CURRENT_LIST_DIR}/cache/CMakeLists.txt.in"
    "${CMAKE_CURRENT_LIST_DIR}/cache/CMakeLists.txt"
    INSTALL_DESTINATION ${CMAKE_CURRENT_BINARY_DIR}/junk
  )
endfunction()

function(reset_test)
  clear_cache()
  FILE(REMOVE_RECURSE ${TEST_BUILD_DIR})
  update_cmake_lists()
endfunction()

set(FIBONACCI_VERSION 1.0)

## Read CPM_SOURCE_CACHE from arguments

reset_test()

execute_process(
  COMMAND 
  ${CMAKE_COMMAND} "-H${CMAKE_CURRENT_LIST_DIR}/cache" "-B${TEST_BUILD_DIR}" "-DCPM_SOURCE_CACHE=${CPM_SOURCE_CACHE_DIR}"
  RESULT_VARIABLE ret
)

ASSERT_EQUAL(${ret} "0")
ASSERT_EXISTS("${CPM_SOURCE_CACHE_DIR}/fibonacci")

FILE(GLOB FIBONACCI_VERSIONs "${CPM_SOURCE_CACHE_DIR}/fibonacci/*")
list(LENGTH FIBONACCI_VERSIONs FIBONACCI_VERSION_count)
ASSERT_EQUAL(${FIBONACCI_VERSION_count} "1")

FILE(GLOB fibonacci_versions "${CPM_SOURCE_CACHE_DIR}/fibonacci/*")
list(LENGTH fibonacci_versions fibonacci_version_count)
ASSERT_EQUAL(${fibonacci_version_count} "1")

## Update dependency and keep CPM_SOURCE_CACHE

set(FIBONACCI_VERSION 2.0)
update_cmake_lists()

execute_process(
  COMMAND 
  ${CMAKE_COMMAND} ${TEST_BUILD_DIR}
  RESULT_VARIABLE ret
)

ASSERT_EQUAL(${ret} "0")

FILE(GLOB FIBONACCI_VERSIONs "${CPM_SOURCE_CACHE_DIR}/fibonacci/*")
list(LENGTH FIBONACCI_VERSIONs FIBONACCI_VERSION_count)
ASSERT_EQUAL(${FIBONACCI_VERSION_count} "2")

## Clear cache and update

clear_cache()

execute_process(
  COMMAND 
  ${CMAKE_COMMAND} ${TEST_BUILD_DIR}
  RESULT_VARIABLE ret
)

ASSERT_EQUAL(${ret} "0")
ASSERT_EXISTS("${CPM_SOURCE_CACHE_DIR}/fibonacci")

## Read CPM_SOURCE_CACHE from environment

reset_test()

execute_process(
  COMMAND 
  ${CMAKE_COMMAND} -E env "CPM_SOURCE_CACHE=${CPM_SOURCE_CACHE_DIR}" ${CMAKE_COMMAND} "-H${CMAKE_CURRENT_LIST_DIR}/cache" "-B${TEST_BUILD_DIR}"
  RESULT_VARIABLE ret
)

ASSERT_EQUAL(${ret} "0")
ASSERT_EXISTS("${CPM_SOURCE_CACHE_DIR}/fibonacci")

## Reuse cached packages for other build

execute_process(
  COMMAND 
  ${CMAKE_COMMAND} -E env "CPM_SOURCE_CACHE=${CPM_SOURCE_CACHE_DIR}" ${CMAKE_COMMAND} "-H${CMAKE_CURRENT_LIST_DIR}/cache" "-B${TEST_BUILD_DIR}-2"
  RESULT_VARIABLE ret
)

ASSERT_EQUAL(${ret} "0")

## Overwrite CPM_SOURCE_CACHE with argument

reset_test()

execute_process(
  COMMAND 
  ${CMAKE_COMMAND} -E env "CPM_SOURCE_CACHE=${CMAKE_CURRENT_BINARY_DIR}/junk" ${CMAKE_COMMAND} "-H${CMAKE_CURRENT_LIST_DIR}/cache" "-B${TEST_BUILD_DIR}" "-DCPM_SOURCE_CACHE=${CPM_SOURCE_CACHE_DIR}"
  RESULT_VARIABLE ret
)

ASSERT_EQUAL(${ret} "0")
ASSERT_EXISTS("${CPM_SOURCE_CACHE_DIR}/fibonacci")

## Use NO_CACHE option

set(FIBONACCI_PACKAGE_ARGS "NO_CACHE YES")
update_cmake_lists()
reset_test()

execute_process(
  COMMAND 
  ${CMAKE_COMMAND} -E env "CPM_SOURCE_CACHE=${CPM_SOURCE_CACHE_DIR}" ${CMAKE_COMMAND} "-H${CMAKE_CURRENT_LIST_DIR}/cache" "-B${TEST_BUILD_DIR}"
  RESULT_VARIABLE ret
)

ASSERT_EQUAL(${ret} "0")
ASSERT_NOT_EXISTS("${CPM_SOURCE_CACHE_DIR}/fibonacci")
