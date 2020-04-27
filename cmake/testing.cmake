
function(ASSERT_EQUAL)
  if (NOT ARGC EQUAL 2) 
    message(FATAL_ERROR "assertion failed: invalid argument count: ${ARGC}")
  endif()

  if (NOT ${ARGV0} STREQUAL ${ARGV1})
    message(FATAL_ERROR "assertion failed: '${ARGV0}' != '${ARGV1}'")
  else()
    message(STATUS "test passed: '${ARGV0}' == '${ARGV1}'")
  endif()
endfunction()

function(ASSERT_EMPTY)
  if (NOT ARGC EQUAL 0) 
    message(FATAL_ERROR "assertion failed: input ${ARGC} not empty: '${ARGV}'")
  endif()
endfunction()

function(ASSERTION_FAILED)
  message(FATAL_ERROR "assertion failed: ${ARGN}")
endfunction()

function(ASSERT_EXISTS file)
  if (NOT EXISTS ${file}) 
    message(FATAL_ERROR "assertion failed: file ${file} does not exist")
  endif()
endfunction()

function(ASSERT_NOT_EXISTS file)
  if (EXISTS ${file}) 
    message(FATAL_ERROR "assertion failed: file ${file} exists")
  endif()
endfunction()
