include(${CPM_PATH}/testing.cmake)

set(TEST_DIR ${CMAKE_CURRENT_BINARY_DIR}/download_only)
file(REMOVE_RECURSE ${TEST_DIR})

# A package whose CMakeLists.txt announces itself, so we can tell if add_subdirectory was called on
# the top level directory or on `sub`.
file(WRITE ${TEST_DIR}/pkg/CMakeLists.txt "message(STATUS \"PKG_TOPLEVEL_ADDED\")\n")
file(WRITE ${TEST_DIR}/pkg/sub/CMakeLists.txt "message(STATUS \"PKG_SUBDIR_ADDED\")\n")
execute_process(
  COMMAND ${CMAKE_COMMAND} -E tar czf ${TEST_DIR}/pkg.tgz CMakeLists.txt sub
  WORKING_DIRECTORY ${TEST_DIR}/pkg
  RESULT_VARIABLE ret
)
assert_equal(${ret} "0")


function(configure_project name)
  set(project_dir ${TEST_DIR}/${name})
  set(build_dir ${TEST_DIR}/${name}-build)
  file(
    WRITE ${project_dir}/CMakeLists.txt
    "cmake_minimum_required(VERSION 3.14 FATAL_ERROR)\n" "project(DownloadOnlyTest NONE)\n"
    "include(${CPM_PATH}/CPM.cmake)\n" "CPMAddPackage(NAME Pkg URL ${TEST_DIR}/pkg.tgz ${ARGN})\n"
    "message(STATUS \"Pkg_SOURCE_DIR=\${Pkg_SOURCE_DIR}\")\n"
  )
  execute_process(
    COMMAND ${CMAKE_COMMAND} -S${project_dir} -B${build_dir}
    RESULT_VARIABLE ret
    OUTPUT_VARIABLE output
    ERROR_VARIABLE error
  )
  if(NOT ret EQUAL 0)
    message(FATAL_ERROR "configure of '${name}' failed:\n${output}\n${error}")
  endif()
  set(${name}_output
      "${output}"
      PARENT_SCOPE
  )
  set(${name}_dir
      "${build_dir}"
      PARENT_SCOPE
  )
endfunction()

function(assert_matches output regex)
  if("${output}" MATCHES "${regex}")
    message(STATUS "test passed: output matches '${regex}'")
  else()
    assertion_failed("output does not match '${regex}':\n${output}")
  endif()
endfunction()

function(assert_not_matches output regex)
  if("${output}" MATCHES "${regex}")
    assertion_failed("output unexpectedly matches '${regex}':\n${output}")
  else()
    message(STATUS "test passed: output does not match '${regex}'")
  endif()
endfunction()

# DOWNLOAD_ONLY must download the package without adding it to the build, and must not create any
# `find_package` redirects or modules that would shadow later `find_package` calls.
function(assert_no_find_package_redirects build_dir)
  file(GLOB_RECURSE redirects "${build_dir}/*-config.cmake" "${build_dir}/*-config-version.cmake"
       "${build_dir}/Find*.cmake"
  )
  if(redirects)
    assertion_failed("unexpected find_package redirects were written: ${redirects}")
  endif()
  message(STATUS "test passed: no find_package redirects were written")
endfunction()

# ---- DOWNLOAD_ONLY YES ----
configure_project(download_only DOWNLOAD_ONLY YES)
assert_matches("${download_only_output}" "Pkg_SOURCE_DIR=[^\n]+")
assert_not_matches("${download_only_output}" "PKG_TOPLEVEL_ADDED|PKG_SUBDIR_ADDED")
assert_no_find_package_redirects("${download_only_dir}")

# ---- DOWNLOAD_ONLY NO must still add the package ----
configure_project(download_only_no DOWNLOAD_ONLY NO)
assert_matches("${download_only_no_output}" "PKG_TOPLEVEL_ADDED")
