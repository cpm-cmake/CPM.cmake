cmake_minimum_required(VERSION 3.5...3.14 FATAL_ERROR)

option(DEFINE_ALTERNATIVE_FUNCTION "define the alternative function" OFF)
option(LEAKED_OPTION "this option will be leaked to the outer scope" OFF)

if(NOT DEFINE_ALTERNATIVE_FUNCTION)
  function(dependency_function)
    message("called external method")
  endfunction()
else()

  # check if list was passed correctly
  set(EXPECTED_LIST "a;b;c")
  if(NOT LIST_ARGUMENT STREQUAL EXPECTED_LIST)
    message(
      FATAL_ERROR
        "list argument not properly passed to dependency: '${LIST_ARGUMENT}' != '${EXPECTED_LIST}'"
    )
  endif()

  function(alternative_dependency_function)
    message("called alternative external method")
  endfunction()
endif()
