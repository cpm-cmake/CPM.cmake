cmake_minimum_required(VERSION 3.14 FATAL_ERROR)

include(${CPM_PATH}/testing.cmake)

message("Passing control to Python")
execute_process(
  COMMAND python3 ${CMAKE_CURRENT_LIST_DIR}/parallelism_test/ProcessSpawner.py ${CMAKE_COMMAND}
          ${CPM_PATH}
  WORKING_DIRECTORY ${CMAKE_CURRENT_LIST_DIR}/parallelism_test/
  RESULT_VARIABLE ret
)

assert_equal(${ret} "0")
