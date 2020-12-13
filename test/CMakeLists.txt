cmake_minimum_required(VERSION 3.14 FATAL_ERROR)

project(CPMTests)

file(GLOB tests "${CMAKE_CURRENT_SOURCE_DIR}/unit/*.cmake")

enable_testing()

foreach(test ${tests})
  message(STATUS "adding test: ${test}")
  add_test(NAME ${test} COMMAND ${CMAKE_COMMAND} -DCPM_PATH=${CMAKE_CURRENT_SOURCE_DIR}/../cmake -P
                                "${test}"
  )
endforeach()

add_custom_target(test-verbose COMMAND ${CMAKE_CTEST_COMMAND} -C Debug --verbose)
