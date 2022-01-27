include(CMakePackageConfigHelpers)
include(${CPM_PATH}/testing.cmake)

set(TEST_BUILD_DIR ${CMAKE_CURRENT_BINARY_DIR}/project-override)

execute_process(COMMAND ${CMAKE_COMMAND} -E rm -rf ${TEST_BUILD_DIR})

configure_package_config_file(
  "${CMAKE_CURRENT_LIST_DIR}/local_dependency/OverrideCMakeLists.txt.in"
  "${CMAKE_CURRENT_LIST_DIR}/local_dependency/CMakeLists.txt"
  INSTALL_DESTINATION ${CMAKE_CURRENT_BINARY_DIR}/junk
)

execute_process(
  COMMAND ${CMAKE_COMMAND} -S${CMAKE_CURRENT_LIST_DIR}/local_dependency -B${TEST_BUILD_DIR}
          -DCPM_Dependency_SOURCE=${CMAKE_CURRENT_LIST_DIR}/local_dependency/dependency
  RESULT_VARIABLE ret
)

assert_equal(${ret} "0")
