cmake_minimum_required(VERSION 3.0 FATAL_ERROR)

option(DEFINE_ALTERNATIVE_FUNCTION "define the alternative function" OFF)
option(LEAKED_OPTION "this option will be leaked to the outer scope" OFF)

if(NOT DEFINE_ALTERNATIVE_FUNCTION)
  function(dependency_function)
    message("called external method")
  endfunction()
else()
  function(alternative_dependency_function)
    message("called alternative external method")
  endfunction()
endif()
