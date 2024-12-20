cmake_minimum_required(VERSION 3.14 FATAL_ERROR)

include(${CPM_PATH}/testing.cmake)
include(CMakePackageConfigHelpers)

set(TEST_BUILD_DIR ${CMAKE_CURRENT_BINARY_DIR}/is_local/)

configure_package_config_file(
  "${CMAKE_CURRENT_LIST_DIR}/is_local/will_be_local/CMakeLists.txt.in"
  "${CMAKE_CURRENT_LIST_DIR}/is_local/will_be_local/CMakeLists.txt"
  INSTALL_DESTINATION ${CMAKE_CURRENT_BINARY_DIR}/is_local/will_be_local/
)

execute_process(
  COMMAND ${CMAKE_COMMAND} "-S${CMAKE_CURRENT_LIST_DIR}/is_local/will_be_local/"
          "-B${TEST_BUILD_DIR}/will_be_local/" "-DCPM_SOURCE_CACHE=${CPM_SOURCE_CACHE_DIR}"
  RESULT_VARIABLE ret
)

assert_equal(${ret} "0")

execute_process(
  COMMAND ${CMAKE_COMMAND} "--build" "${TEST_BUILD_DIR}/will_be_local/" "--verbose"
  RESULT_VARIABLE ret
)

assert_equal(${ret} "0")

execute_process(
  COMMAND ${CMAKE_COMMAND} "--install" "${TEST_BUILD_DIR}/will_be_local/" "--prefix"
          "${TEST_BUILD_DIR}/install_dir" RESULT_VARIABLE ret
)

assert_equal(${ret} "0")

# It's better to have this layer of indirection, because we need to add
# -DCMAKE_PREFIX_PATH=binfolder/is_local/will_be_local/install_dir
configure_package_config_file(
  "${CMAKE_CURRENT_LIST_DIR}/is_local/CMakeLists.txt.in"
  "${CMAKE_CURRENT_LIST_DIR}/is_local/CMakeLists.txt"
  INSTALL_DESTINATION ${CMAKE_CURRENT_BINARY_DIR}/is_local/
)

execute_process(
  COMMAND
    ${CMAKE_COMMAND} "-S${CMAKE_CURRENT_LIST_DIR}/is_local/" "-B${TEST_BUILD_DIR}/"
    "-DCMAKE_PREFIX_PATH=${TEST_BUILD_DIR}/install_dir/"
    "-DCPM_SOURCE_CACHE=${CPM_SOURCE_CACHE_DIR}"
  RESULT_VARIABLE ret
)

assert_equal(${ret} "0")

execute_process(
  COMMAND ${CMAKE_COMMAND} "--build" "${TEST_BUILD_DIR}/" "--verbose" RESULT_VARIABLE ret
)

assert_equal(${ret} "0")
