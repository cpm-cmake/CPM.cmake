
include(CMakePackageConfigHelpers)
include(${CPM_PATH}/testing.cmake)

set(TEST_BUILD_DIR ${CMAKE_CURRENT_BINARY_DIR}/package-lock)

function(configureWithDeclare DECLARE_DEPENDENCY)
  execute_process(COMMAND ${CMAKE_COMMAND} -E rm -rf ${TEST_BUILD_DIR})

  if (DECLARE_DEPENDENCY)
    set(PREPARE_CODE "CPMDeclarePackage(Dependency
      NAME Dependency 
      SOURCE_DIR ${CMAKE_CURRENT_LIST_DIR}/test_project/dependency
    )")
  else()
    set(PREPARE_CODE "")
  endif()

  configure_package_config_file(
    "${CMAKE_CURRENT_LIST_DIR}/test_project/PackageLockCMakeLists.txt.in"
    "${CMAKE_CURRENT_LIST_DIR}/test_project/CMakeLists.txt"
    INSTALL_DESTINATION ${CMAKE_CURRENT_BINARY_DIR}/junk
  )

  execute_process(
    COMMAND ${CMAKE_COMMAND} -H${CMAKE_CURRENT_LIST_DIR}/test_project -B${TEST_BUILD_DIR}
    RESULT_VARIABLE ret
  )

  ASSERT_EQUAL(${ret} "0")
endfunction()

function(updatePackageLock)
  execute_process(
    COMMAND ${CMAKE_COMMAND} --build ${TEST_BUILD_DIR} --target cpm-update-package-lock
    RESULT_VARIABLE ret
  )

  ASSERT_EQUAL(${ret} "0")
endfunction()

execute_process(COMMAND ${CMAKE_COMMAND} -E rm -f ${CMAKE_CURRENT_LIST_DIR}/test_project/package-lock.cmake)
configureWithDeclare(YES)
ASSERT_NOT_EXISTS(${CMAKE_CURRENT_LIST_DIR}/test_project/package-lock.cmake)
updatePackageLock()
ASSERT_EXISTS(${CMAKE_CURRENT_LIST_DIR}/test_project/package-lock.cmake)
configureWithDeclare(NO)

