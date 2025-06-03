cmake_minimum_required(VERSION 3.14 FATAL_ERROR)

include(${CPM_PATH}/testing.cmake)
include(${CPM_PATH}/CPM.cmake)

# ----------------------------------------------------------------------------------------
# Setup: Define common environment
# ----------------------------------------------------------------------------------------
set(CPM_CURRENT_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}")

# ----------------------------------------------------------------------------------------
# Test Case 1: Single patch file
# ----------------------------------------------------------------------------------------
function(run_test_single_patch)
  set(_patch1 "${CMAKE_CURRENT_BINARY_DIR}/dummy1.patch")
  file(WRITE "${_patch1}" "dummy patch content")

  unset(CPM_ARGS_UNPARSED_ARGUMENTS)
  cpm_add_patches("${_patch1}")

  list(FIND CPM_ARGS_UNPARSED_ARGUMENTS "PATCH_COMMAND" _idx1)
  assert_not_equal("${_idx1}" "-1")

  math(EXPR _start1 "${_idx1} + 1")
  list(SUBLIST CPM_ARGS_UNPARSED_ARGUMENTS ${_start1} -1 _args1)

  set(_found1 FALSE)
  foreach(arg IN LISTS _args1)
    if(arg MATCHES "PATCH_FILES=.*dummy1\\.patch")
      set(_found1 TRUE)
    endif()
  endforeach()
  assert_truthy(_found1)

  file(REMOVE "${_patch1}")
endfunction()

# ----------------------------------------------------------------------------------------
# Test Case 2: Multiple patch files
# ----------------------------------------------------------------------------------------
function(run_test_multiple_patches)
  set(_patch2 "${CMAKE_CURRENT_BINARY_DIR}/dummy2.patch")
  set(_patch3 "${CMAKE_CURRENT_BINARY_DIR}/dummy3.patch")
  file(WRITE "${_patch2}" "dummy patch 2")
  file(WRITE "${_patch3}" "dummy patch 3")

  unset(CPM_ARGS_UNPARSED_ARGUMENTS)
  cpm_add_patches("${_patch2}" "${_patch3}")

  list(FIND CPM_ARGS_UNPARSED_ARGUMENTS "PATCH_COMMAND" _idx2)
  assert_not_equal("${_idx2}" "-1")

  math(EXPR _start2 "${_idx2} + 1")
  list(SUBLIST CPM_ARGS_UNPARSED_ARGUMENTS ${_start2} -1 _args2)

  set(_found2 FALSE)
  set(_found3 FALSE)

  foreach(arg IN LISTS _args2)
    if(arg MATCHES "dummy2\\.patch")
      set(_found2 TRUE)
    endif()
    if(arg MATCHES "dummy3\\.patch")
      set(_found3 TRUE)
    endif()
  endforeach()

  assert_truthy(_found2)
  assert_truthy(_found3)

  file(REMOVE "${_patch2}")
  file(REMOVE "${_patch3}")
endfunction()

# ----------------------------------------------------------------------------------------
# Test Case 3: No patch files
# ----------------------------------------------------------------------------------------
function(run_test_no_patches)
  unset(CPM_ARGS_UNPARSED_ARGUMENTS)
  cpm_add_patches()

  assert_not_defined(CPM_ARGS_UNPARSED_ARGUMENTS)
endfunction()

# ----------------------------------------------------------------------------------------
# Run all test cases
# ----------------------------------------------------------------------------------------
run_test_single_patch()
run_test_multiple_patches()
run_test_no_patches()
