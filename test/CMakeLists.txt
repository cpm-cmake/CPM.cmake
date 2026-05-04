cmake_minimum_required(VERSION 3.14 FATAL_ERROR)

project(CPMTests)

file(GLOB tests "${CMAKE_CURRENT_SOURCE_DIR}/unit/*.cmake")

enable_testing()

foreach(test ${tests})
  get_filename_component(test_name ${test} NAME_WE)
  message(STATUS "adding test: ${test} as ${test_name}")
  add_test(NAME ${test_name} COMMAND ${CMAKE_COMMAND} -DCPM_PATH=${CMAKE_CURRENT_SOURCE_DIR}/../cmake -P
                                "${test}"
  )
endforeach()

add_custom_target(test-verbose COMMAND ${CMAKE_CTEST_COMMAND} -C Debug --verbose)

add_subdirectory(style)
