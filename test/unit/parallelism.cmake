cmake_minimum_required(VERSION 3.14 FATAL_ERROR)

include(${CPM_PATH}/testing.cmake)
include(${CPM_PATH}/CPM.cmake)

set(TEST_DIR ${CMAKE_CURRENT_LIST_DIR}/parallelism_test/)

# A Python script that spawns new CMake processes is called. Will return 0 if no CMake errors were
# encountered.
message("Passing control to Python")
execute_process(
  COMMAND python3 ${TEST_DIR}/ProcessSpawner.py ${CMAKE_COMMAND} ${CPM_PATH}
  WORKING_DIRECTORY ${TEST_DIR}
  RESULT_VARIABLE ret
)
assert_equal(${ret} "0")

# Find the git working directory.
file(
  GLOB children
  RELATIVE ${TEST_DIR}/deps/fmt
  ${TEST_DIR}/deps/fmt/*
)
list(GET children 0 dir)

# Verify that the git cache is clean. Tag here must match tag in
# test/unit/parallelism_test/CMakeLists.txt:9
cpm_check_git_working_dir_is_clean(${dir} 7.1.3 clean)
assert_truthy(clean)

# The test passes if no CMake errors were encountered in any subprocess, and the git cache exists,
# and is clean.
