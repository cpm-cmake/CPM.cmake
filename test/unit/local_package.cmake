include(${CPM_PATH}/testing.cmake)
include(CMakePackageConfigHelpers)

set(TEST_BUILD_DIR ${CMAKE_CURRENT_BINARY_DIR}/local_package)

configure_package_config_file(
  "${CMAKE_CURRENT_LIST_DIR}/local_package/CMakeLists.txt.in"
  "${CMAKE_CURRENT_LIST_DIR}/local_package/CMakeLists.txt"
  INSTALL_DESTINATION ${CMAKE_CURRENT_BINARY_DIR}/junk
)

execute_process(
  COMMAND ${CMAKE_COMMAND} "-S${CMAKE_CURRENT_LIST_DIR}/local_package" "-B${TEST_BUILD_DIR}"
          "-DCPM_LOCAL_PACKAGES_ONLY=ON"
  RESULT_VARIABLE ret
)

assert_equal(${ret} "0")
