include(CMakePackageConfigHelpers)
include(${CPM_PATH}/testing.cmake)

set(TEST_BUILD_DIR ${CMAKE_CURRENT_BINARY_DIR}/exclude_from_all)

function(init_project EXCLUDE_FROM_ALL)
  configure_package_config_file(
    "${CMAKE_CURRENT_LIST_DIR}/broken_dependency/CMakeLists.txt.in"
    "${CMAKE_CURRENT_LIST_DIR}/broken_dependency/CMakeLists.txt"
    INSTALL_DESTINATION ${CMAKE_CURRENT_BINARY_DIR}/junk
  )

  execute_process(
    COMMAND ${CMAKE_COMMAND} "-H${CMAKE_CURRENT_LIST_DIR}/broken_dependency" "-B${TEST_BUILD_DIR}"
    RESULT_VARIABLE ret
  )

  assert_equal(${ret} "0")
endfunction()

function(build_project expected_success)
  execute_process(COMMAND ${CMAKE_COMMAND} "--build" "${TEST_BUILD_DIR}" RESULT_VARIABLE ret)

  if(expected_success)
    assert_equal(${ret} 0)
  else()
    assert_not_equal(${ret} 0)
  endif()
endfunction()

init_project(FALSE)
build_project(FALSE)

init_project(TRUE)
build_project(TRUE)
