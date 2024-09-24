include(CMakePackageConfigHelpers)
include(${CPM_PATH}/testing.cmake)

set(TEST_BUILD_DIR ${CMAKE_CURRENT_BINARY_DIR}/modules)

function(init_project_with_dependency TEST_DEPENDENCY_NAME TEST_CANT_FIND_PACKAGE_NAME)
  set(TEST_FIND_PACKAGE ON)
  configure_package_config_file(
    "${CMAKE_CURRENT_LIST_DIR}/local_dependency/ModuleCMakeLists.txt.in"
    "${CMAKE_CURRENT_LIST_DIR}/local_dependency/CMakeLists.txt"
    INSTALL_DESTINATION ${CMAKE_CURRENT_BINARY_DIR}/junk
  )

  execute_process(
    COMMAND ${CMAKE_COMMAND} "-S${CMAKE_CURRENT_LIST_DIR}/local_dependency" "-B${TEST_BUILD_DIR}"
    RESULT_VARIABLE ret
  )

  assert_equal(${ret} "0")
endfunction()

init_project_with_dependency(A B)
init_project_with_dependency(B A)

if(${CMAKE_VERSION} VERSION_GREATER_EQUAL "3.24.0")
  set(TEST_FIND_PACKAGE_CONFIG CONFIG)
  init_project_with_dependency(A B)
  init_project_with_dependency(B A)

  # Test the fallback path for CMake <3.24 works
  set(TEST_FIND_PACKAGE_CONFIG)
  set(TEST_FORCE_MODULE_MODE ON)
  init_project_with_dependency(A B)
  init_project_with_dependency(B A)
endif()
