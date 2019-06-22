

function(ASSERT_EQUAL)
  if (NOT ARGC EQUAL 2) 
    message(FATAL_ERROR "assertion failed: invalid argument count: ${ARGC}")
  endif()

  if (NOT ${ARGV0} EQUAL ${ARGV1})
    message(FATAL_ERROR "assertion failed: '${ARGV0}' != '${ARGV1}'")
  endif()
endfunction()
