cmake_minimum_required(VERSION 3.0 FATAL_ERROR)

option(DEFINE_ALTERNATIVE_FUNCTION "define the alternative function" OFF)
option(LEAKED_OPTION "this option will be leaked to the outer scope" OFF)

if(NOT DEFINE_ALTERNATIVE_FUNCTION)
  function(dependency_function)
    message("called external method")
  endfunction()
else()

  # check if list was passed correctly
  if(NOT "${LIST_ARGUMENT}" STREQUAL "a;b;c")
    message(FATAL_ERROR "list argument not properly passed to dependency: '${LIST_ARGUMENT}'")
  endif()

  function(alternative_dependency_function)
    message("called alternative external method")
  endfunction()
endif()
