
include(CMakePackageConfigHelpers)
include(${CPM_PATH}/testing.cmake)

set(TEST_BUILD_DIR ${CMAKE_CURRENT_BINARY_DIR}/source_dir)

set(TEST_DEPENDENCY_NAME Dependency)

configure_package_config_file(
  "${CMAKE_CURRENT_LIST_DIR}/test_project/ModuleCMakeLists.txt.in"
  "${CMAKE_CURRENT_LIST_DIR}/test_project/CMakeLists.txt"
  INSTALL_DESTINATION ${CMAKE_CURRENT_BINARY_DIR}/junk
)

execute_process(
  COMMAND 
  ${CMAKE_COMMAND} "-H${CMAKE_CURRENT_LIST_DIR}/test_project" "-B${TEST_BUILD_DIR}"
  RESULT_VARIABLE ret
)

ASSERT_EQUAL(${ret} "0")
