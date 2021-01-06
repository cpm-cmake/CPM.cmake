include(CMakePackageConfigHelpers)
include(${CPM_PATH}/testing.cmake)

set(TEST_BUILD_DIR ${CMAKE_CURRENT_BINARY_DIR}/modules)

function(init_project_with_dependency TEST_DEPENDENCY_NAME)
  configure_package_config_file(
    "${CMAKE_CURRENT_LIST_DIR}/local_dependency/ModuleCMakeLists.txt.in"
    "${CMAKE_CURRENT_LIST_DIR}/local_dependency/CMakeLists.txt"
    INSTALL_DESTINATION ${CMAKE_CURRENT_BINARY_DIR}/junk
  )

  execute_process(
    COMMAND ${CMAKE_COMMAND} "-H${CMAKE_CURRENT_LIST_DIR}/local_dependency" "-B${TEST_BUILD_DIR}"
    RESULT_VARIABLE ret
  )

  assert_equal(${ret} "0")
endfunction()

init_project_with_dependency(A)
assert_exists(${TEST_BUILD_DIR}/CPM_modules)
assert_exists(${TEST_BUILD_DIR}/CPM_modules/FindA.cmake)
assert_not_exists(${TEST_BUILD_DIR}/CPM_modules/FindB.cmake)

init_project_with_dependency(B)
assert_not_exists(${TEST_BUILD_DIR}/CPM_modules/FindA.cmake)
assert_exists(${TEST_BUILD_DIR}/CPM_modules/FindB.cmake)
