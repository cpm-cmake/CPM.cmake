include(CMakePackageConfigHelpers)
include(${CPM_PATH}/testing.cmake)

set(TEST_BUILD_DIR ${CMAKE_CURRENT_BINARY_DIR}/package-lock)

function(configure_with_declare DECLARE_DEPENDENCY)
  execute_process(COMMAND ${CMAKE_COMMAND} -E rm -rf ${TEST_BUILD_DIR})

  if(DECLARE_DEPENDENCY)
    set(PREPARE_CODE
        "CPMDeclarePackage(Dependency
      NAME Dependency
      SOURCE_DIR ${CMAKE_CURRENT_LIST_DIR}/local_dependency/dependency
    )"
    )
  else()
    set(PREPARE_CODE "")
  endif()

  configure_package_config_file(
    "${CMAKE_CURRENT_LIST_DIR}/local_dependency/PackageLockCMakeLists.txt.in"
    "${CMAKE_CURRENT_LIST_DIR}/local_dependency/CMakeLists.txt"
    INSTALL_DESTINATION ${CMAKE_CURRENT_BINARY_DIR}/junk
  )

  execute_process(
    COMMAND ${CMAKE_COMMAND} -S${CMAKE_CURRENT_LIST_DIR}/local_dependency -B${TEST_BUILD_DIR}
            -DCPM_INCLUDE_ALL_IN_PACKAGE_LOCK=1 RESULT_VARIABLE ret
  )

  assert_equal(${ret} "0")
endfunction()

function(update_package_lock)
  execute_process(
    COMMAND ${CMAKE_COMMAND} --build ${TEST_BUILD_DIR} --target cpm-update-package-lock
    RESULT_VARIABLE ret
  )

  assert_equal(${ret} "0")
endfunction()

execute_process(
  COMMAND ${CMAKE_COMMAND} -E rm -f ${CMAKE_CURRENT_LIST_DIR}/local_dependency/package-lock.cmake
)
configure_with_declare(YES)
assert_not_exists(${CMAKE_CURRENT_LIST_DIR}/local_dependency/package-lock.cmake)
update_package_lock()
assert_exists(${CMAKE_CURRENT_LIST_DIR}/local_dependency/package-lock.cmake)
configure_with_declare(NO)
execute_process(
  COMMAND ${CMAKE_COMMAND} -E rm -f ${CMAKE_CURRENT_LIST_DIR}/local_dependency/package-lock.cmake
)
