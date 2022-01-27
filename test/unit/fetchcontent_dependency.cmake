cmake_minimum_required(VERSION 3.14 FATAL_ERROR)

include(${CPM_PATH}/testing.cmake)
include(CMakePackageConfigHelpers)

set(CPM_SOURCE_CACHE_DIR "${CMAKE_CURRENT_BINARY_DIR}/CPM")
set(TEST_BUILD_DIR ${CMAKE_CURRENT_BINARY_DIR}/fetchcontent_dependency)

function(clear_cache)
  message(STATUS "clearing CPM cache")
  file(REMOVE_RECURSE ${CPM_SOURCE_CACHE_DIR})
  assert_not_exists("${CPM_SOURCE_CACHE_DIR}")
endfunction()

function(update_cmake_lists)
  configure_package_config_file(
    "${CMAKE_CURRENT_LIST_DIR}/fetchcontent_dependency/CMakeLists.txt.in"
    "${CMAKE_CURRENT_LIST_DIR}/fetchcontent_dependency/CMakeLists.txt"
    INSTALL_DESTINATION ${CMAKE_CURRENT_BINARY_DIR}/junk
  )
endfunction()

function(reset_test)
  clear_cache()
  file(REMOVE_RECURSE ${TEST_BUILD_DIR})
  update_cmake_lists()
endfunction()

# Read CPM_SOURCE_CACHE from arguments

reset_test()

execute_process(
  COMMAND ${CMAKE_COMMAND} "-S${CMAKE_CURRENT_LIST_DIR}/fetchcontent_dependency"
          "-B${TEST_BUILD_DIR}" "-DCPM_SOURCE_CACHE=${CPM_SOURCE_CACHE_DIR}" RESULT_VARIABLE ret
)

assert_equal(${ret} "0")
