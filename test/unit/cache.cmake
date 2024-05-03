cmake_minimum_required(VERSION 3.14 FATAL_ERROR)

include(${CPM_PATH}/testing.cmake)
include(CMakePackageConfigHelpers)

set(CPM_SOURCE_CACHE_DIR "${CMAKE_CURRENT_BINARY_DIR}/CPM")
set(TEST_BUILD_DIR ${CMAKE_CURRENT_BINARY_DIR}/remote_dependency)

function(clear_cache)
  message(STATUS "clearing CPM cache")
  file(REMOVE_RECURSE ${CPM_SOURCE_CACHE_DIR})
  assert_not_exists("${CPM_SOURCE_CACHE_DIR}")
endfunction()

function(update_cmake_lists)
  configure_package_config_file(
    "${CMAKE_CURRENT_LIST_DIR}/remote_dependency/CMakeLists.txt.in"
    "${CMAKE_CURRENT_LIST_DIR}/remote_dependency/CMakeLists.txt"
    INSTALL_DESTINATION ${CMAKE_CURRENT_BINARY_DIR}/junk
  )
endfunction()

function(reset_test)
  clear_cache()
  file(REMOVE_RECURSE ${TEST_BUILD_DIR})
  update_cmake_lists()
endfunction()

function(assert_cache_directory_count directory count)
  set(version_count 0)
  file(GLOB potential_versions ${directory})
  foreach(entry ${potential_versions})
    if(IS_DIRECTORY ${entry})
      math(EXPR version_count "${version_count} + 1")
    endif()
  endforeach()
  assert_equal("${version_count}" "${count}")
endfunction()

set(FIBONACCI_VERSION 1.0)

# Read CPM_SOURCE_CACHE from arguments

reset_test()

execute_process(
  COMMAND ${CMAKE_COMMAND} "-S${CMAKE_CURRENT_LIST_DIR}/remote_dependency" "-B${TEST_BUILD_DIR}"
          "-DCPM_SOURCE_CACHE=${CPM_SOURCE_CACHE_DIR}" RESULT_VARIABLE ret
)

assert_equal(${ret} "0")
assert_exists("${CPM_SOURCE_CACHE_DIR}/fibonacci")

assert_cache_directory_count("${CPM_SOURCE_CACHE_DIR}/fibonacci/*" 1)

# Update dependency and keep CPM_SOURCE_CACHE

set(FIBONACCI_VERSION 2.0)
update_cmake_lists()

execute_process(COMMAND ${CMAKE_COMMAND} ${TEST_BUILD_DIR} RESULT_VARIABLE ret)
assert_equal(${ret} "0")

assert_cache_directory_count("${CPM_SOURCE_CACHE_DIR}/fibonacci/*" 2)

# Clear cache and update

clear_cache()

execute_process(COMMAND ${CMAKE_COMMAND} ${TEST_BUILD_DIR} RESULT_VARIABLE ret)

assert_equal(${ret} "0")
assert_exists("${CPM_SOURCE_CACHE_DIR}/fibonacci")

# Read CPM_SOURCE_CACHE from environment

reset_test()

execute_process(
  COMMAND ${CMAKE_COMMAND} -E env "CPM_SOURCE_CACHE=${CPM_SOURCE_CACHE_DIR}" ${CMAKE_COMMAND}
          "-S${CMAKE_CURRENT_LIST_DIR}/remote_dependency" "-B${TEST_BUILD_DIR}" RESULT_VARIABLE ret
)

assert_equal(${ret} "0")
assert_exists("${CPM_SOURCE_CACHE_DIR}/fibonacci")

# Reuse cached packages for other build

execute_process(
  COMMAND ${CMAKE_COMMAND} -E env "CPM_SOURCE_CACHE=${CPM_SOURCE_CACHE_DIR}" ${CMAKE_COMMAND}
          "-S${CMAKE_CURRENT_LIST_DIR}/remote_dependency" "-B${TEST_BUILD_DIR}-2"
  RESULT_VARIABLE ret
)

assert_equal(${ret} "0")

# Overwrite CPM_SOURCE_CACHE with argument

reset_test()

execute_process(
  COMMAND
    ${CMAKE_COMMAND} -E env "CPM_SOURCE_CACHE=${CMAKE_CURRENT_BINARY_DIR}/junk" ${CMAKE_COMMAND}
    "-S${CMAKE_CURRENT_LIST_DIR}/remote_dependency" "-B${TEST_BUILD_DIR}"
    "-DCPM_SOURCE_CACHE=${CPM_SOURCE_CACHE_DIR}"
  RESULT_VARIABLE ret
)

assert_equal(${ret} "0")
assert_exists("${CPM_SOURCE_CACHE_DIR}/fibonacci")

# Use NO_CACHE option

set(FIBONACCI_PACKAGE_ARGS "NO_CACHE YES")
set(FIBONACCI_VERSION 1.0)
update_cmake_lists()
reset_test()

execute_process(
  COMMAND ${CMAKE_COMMAND} -E env "CPM_SOURCE_CACHE=${CPM_SOURCE_CACHE_DIR}" ${CMAKE_COMMAND}
          "-S${CMAKE_CURRENT_LIST_DIR}/remote_dependency" "-B${TEST_BUILD_DIR}" RESULT_VARIABLE ret
)

assert_equal(${ret} "0")
assert_not_exists("${CPM_SOURCE_CACHE_DIR}/fibonacci")

# Use commit hash after version

set(FIBONACCI_PACKAGE_ARGS "NO_CACHE YES GIT_TAG e9ebf168ca0fffaa4ef8c6fefc6346aaa22f6ed5")
set(FIBONACCI_VERSION 1.1)
update_cmake_lists()

execute_process(
  COMMAND ${CMAKE_COMMAND} -E env "CPM_SOURCE_CACHE=${CPM_SOURCE_CACHE_DIR}" ${CMAKE_COMMAND}
          "-S${CMAKE_CURRENT_LIST_DIR}/remote_dependency" "-B${TEST_BUILD_DIR}" RESULT_VARIABLE ret
)

assert_equal(${ret} "0")
assert_not_exists("${CPM_SOURCE_CACHE_DIR}/fibonacci")

# Use custom cache directory

set(FIBONACCI_PACKAGE_ARGS
    "CUSTOM_CACHE_KEY my_custom_unique_dir GIT_TAG e9ebf168ca0fffaa4ef8c6fefc6346aaa22f6ed5"
)
set(FIBONACCI_VERSION 1.1)
update_cmake_lists()

execute_process(
  COMMAND ${CMAKE_COMMAND} -E env "CPM_SOURCE_CACHE=${CPM_SOURCE_CACHE_DIR}" ${CMAKE_COMMAND}
          "-S${CMAKE_CURRENT_LIST_DIR}/remote_dependency" "-B${TEST_BUILD_DIR}" RESULT_VARIABLE ret
)

assert_equal(${ret} "0")
assert_exists("${CPM_SOURCE_CACHE_DIR}/fibonacci/my_custom_unique_dir")

# Cache checksum

reset_test()
set(FIBONACCI_VERSION 1.1)
set(FIBONACCI_GIT_TAG "GIT_TAG e9ebf168ca0fffaa4ef8c6fefc6346aaa22f6ed5")
set(TEST_CHECKSUM_DIR "${CPM_SOURCE_CACHE_DIR}/fibonacci/my_checksummed_dir")
set(TEST_CHECKSUM_VALUE
    cf83e1357eefb8bdf1542850d66d8007d620e4050b5715dc83f4a921d36ce9ce47d0d13c5d85f2b0ff8318d2877eec2f63b931bd47417a81a538327af927da3e
)

set(CHECKSUM_COMMAND "${CMAKE_CURRENT_LIST_DIR}/checksum_directory.sh")
set(INCORRECT_CHECKSUM_RESULT "1")
set(IGNORE_CHECKSUM_TEST)
if(CMAKE_HOST_WIN32)
  # checksum example is not adapted to Windows (Cygwin and msys could work though)
  set(CHECKSUM_COMMAND "")
  set(TEST_CHECKSUM_VALUE)
  set(IGNORE_CHECKSUM_TEST True)
elseif(CMAKE_HOST_APPLE)
  set(TEST_CHECKSUM_VALUE
      cf83e1357eefb8bdf1542850d66d8007d620e4050b5715dc83f4a921d36ce9ce47d0d13c5d85f2b0ff8318d2877eec2f63b931bd47417a81a538327af927da3e
  )
endif()

# OK download

set(FIBONACCI_PACKAGE_ARGS
    "${FIBONACCI_GIT_TAG} CUSTOM_CACHE_KEY my_checksummed_dir CUSTOM_CACHE_CHECKSUM_COMMAND \"${CHECKSUM_COMMAND}\""
)
update_cmake_lists()

execute_process(
  COMMAND ${CMAKE_COMMAND} -E env "CPM_SOURCE_CACHE=${CPM_SOURCE_CACHE_DIR}" ${CMAKE_COMMAND}
          "-S${CMAKE_CURRENT_LIST_DIR}/remote_dependency" "-B${TEST_BUILD_DIR}" RESULT_VARIABLE ret
)

assert_equal(${ret} "0")
assert_exists("${TEST_CHECKSUM_DIR}.download")
file(READ "${TEST_CHECKSUM_DIR}.download" chksum)
assert_equal("${chksum}" "${TEST_CHECKSUM_VALUE}")

# Test download again if .download file is missing

file(REMOVE "${TEST_CHECKSUM_DIR}.download")
file(REMOVE "${TEST_CHECKSUM_DIR}/include/fibonacci.h")

set(FIBONACCI_PACKAGE_ARGS
    "${FIBONACCI_GIT_TAG} CUSTOM_CACHE_KEY my_checksummed_dir CUSTOM_CACHE_CHECKSUM_COMMAND \"${CHECKSUM_COMMAND}\""
)
update_cmake_lists()

execute_process(
  COMMAND ${CMAKE_COMMAND} -E env "CPM_SOURCE_CACHE=${CPM_SOURCE_CACHE_DIR}" ${CMAKE_COMMAND}
          "-S${CMAKE_CURRENT_LIST_DIR}/remote_dependency" "-B${TEST_BUILD_DIR}" RESULT_VARIABLE ret
)

assert_equal(${ret} "0")
assert_exists("${TEST_CHECKSUM_DIR}.download")
assert_exists("${TEST_CHECKSUM_DIR}/include/fibonacci.h")

# check checksum for download

set(FIBONACCI_PACKAGE_ARGS
    "${FIBONACCI_GIT_TAG} CUSTOM_CACHE_KEY my_checksummed_dir CUSTOM_CACHE_CHECKSUM_COMMAND \"${CHECKSUM_COMMAND}\""
)
update_cmake_lists()

execute_process(
  COMMAND ${CMAKE_COMMAND} -E env "CPM_SOURCE_CACHE=${CPM_SOURCE_CACHE_DIR}" ${CMAKE_COMMAND}
          "-S${CMAKE_CURRENT_LIST_DIR}/remote_dependency" "-B${TEST_BUILD_DIR}" RESULT_VARIABLE ret
)

assert_equal(${ret} "0")

# check checksum for download, provided

set(FIBONACCI_PACKAGE_ARGS
    "${FIBONACCI_GIT_TAG} CUSTOM_CACHE_KEY my_checksummed_dir CUSTOM_CACHE_CHECKSUM_COMMAND \"${CHECKSUM_COMMAND}\" CUSTOM_CACHE_CHECKSUM_VALUE ${TEST_CHECKSUM_VALUE}"
)
update_cmake_lists()

execute_process(
  COMMAND ${CMAKE_COMMAND} -E env "CPM_SOURCE_CACHE=${CPM_SOURCE_CACHE_DIR}" ${CMAKE_COMMAND}
          "-S${CMAKE_CURRENT_LIST_DIR}/remote_dependency" "-B${TEST_BUILD_DIR}" RESULT_VARIABLE ret
)

assert_equal(${ret} "0")

# check checksum for download, provided incorrect, this will print a fatal_error (red) error to the
# console

set(FIBONACCI_PACKAGE_ARGS
    "${FIBONACCI_GIT_TAG} CUSTOM_CACHE_KEY my_checksummed_dir CUSTOM_CACHE_CHECKSUM_COMMAND \"${CHECKSUM_COMMAND}\" CUSTOM_CACHE_CHECKSUM_VALUE invalid_checksum_value"
)
update_cmake_lists()

execute_process(
  COMMAND ${CMAKE_COMMAND} -E env "CPM_SOURCE_CACHE=${CPM_SOURCE_CACHE_DIR}" ${CMAKE_COMMAND}
          "-S${CMAKE_CURRENT_LIST_DIR}/remote_dependency" "-B${TEST_BUILD_DIR}" RESULT_VARIABLE ret
)

if(NOT IGNORE_CHECKSUM_TEST)
  assert_equal(${ret} "1")
endif()

# redownload when checksum is changed

set(FIBONACCI_PACKAGE_ARGS
    "${FIBONACCI_GIT_TAG} CUSTOM_CACHE_KEY my_checksummed_dir CUSTOM_CACHE_CHECKSUM_COMMAND \"${CHECKSUM_COMMAND}\" CUSTOM_CACHE_CHECKSUM_VALUE ${TEST_CHECKSUM_VALUE}"
)
update_cmake_lists()

# dummy change, to trigger checksum mismatch
file(WRITE "${TEST_CHECKSUM_DIR}/fail_checksum.txt" "dummy")

execute_process(
  COMMAND ${CMAKE_COMMAND} -E env "CPM_SOURCE_CACHE=${CPM_SOURCE_CACHE_DIR}" ${CMAKE_COMMAND}
          "-S${CMAKE_CURRENT_LIST_DIR}/remote_dependency" "-B${TEST_BUILD_DIR}" RESULT_VARIABLE ret
)

assert_equal(${ret} "0")
if(NOT IGNORE_CHECKSUM_TEST)
  assert_not_exists("${TEST_CHECKSUM_DIR}/fail_checksum.txt")
endif()

# redownload when checksum is changed

set(FIBONACCI_PACKAGE_ARGS
    "${FIBONACCI_GIT_TAG} CUSTOM_CACHE_KEY my_checksummed_dir CUSTOM_CACHE_CHECKSUM_VALUE ${TEST_CHECKSUM_VALUE}"
)
update_cmake_lists()

# dummy change, to trigger checksum mismatch
file(WRITE "${TEST_CHECKSUM_DIR}/fail_checksum.txt" "dummy")

execute_process(
  COMMAND ${CMAKE_COMMAND} -E env "CPM_SOURCE_CACHE=${CPM_SOURCE_CACHE_DIR}" ${CMAKE_COMMAND}
          "-S${CMAKE_CURRENT_LIST_DIR}/remote_dependency" "-B${TEST_BUILD_DIR}" RESULT_VARIABLE ret
)

assert_equal(${ret} "0")
if(NOT IGNORE_CHECKSUM_TEST)
  assert_not_exists("${TEST_CHECKSUM_DIR}/fail_checksum.txt")
endif()
