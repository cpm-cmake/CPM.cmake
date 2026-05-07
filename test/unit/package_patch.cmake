cmake_minimum_required(VERSION 3.14 FATAL_ERROR)

set(CPM_DONT_CREATE_PACKAGE_LOCK TRUE)
include(${CPM_PATH}/testing.cmake)
include(${CPM_PATH}/CPM.cmake)

function(write_patch patch_file old_text new_text)
  file(
    WRITE "${patch_file}"
    "diff --git a/input.txt b/input.txt
--- a/input.txt
+++ b/input.txt
@@ -1 +1 @@
-${old_text}
+${new_text}
"
  )
endfunction()

function(get_patch_script output_variable)
  list(FIND CPM_ARGS_UNPARSED_ARGUMENTS "PATCH_COMMAND" patch_command_index)
  assert_not_equal("${patch_command_index}" "-1")

  math(EXPR patch_script_index "${patch_command_index} + 3")
  list(GET CPM_ARGS_UNPARSED_ARGUMENTS ${patch_script_index} patch_script)
  assert_exists("${patch_script}")

  set(${output_variable}
      "${patch_script}"
      PARENT_SCOPE
  )
endfunction()

function(run_patch_script patch_script working_directory)
  execute_process(
    COMMAND "${CMAKE_COMMAND}" -P "${patch_script}"
    WORKING_DIRECTORY "${working_directory}"
    RESULT_VARIABLE script_result
    OUTPUT_VARIABLE script_output
    ERROR_VARIABLE script_error
  )

  if(NOT script_result EQUAL 0)
    message(FATAL_ERROR "Patch script failed:\n${script_output}\n${script_error}")
  endif()
endfunction()

function(run_patch_script_expect_failure patch_script working_directory)
  execute_process(
    COMMAND "${CMAKE_COMMAND}" -P "${patch_script}"
    WORKING_DIRECTORY "${working_directory}"
    RESULT_VARIABLE script_result
    OUTPUT_VARIABLE script_output
    ERROR_VARIABLE script_error
  )

  assert_not_equal("${script_result}" "0")
  string(FIND "${script_error}" "Working directory:" working_directory_index)
  string(FIND "${script_error}" "Patch executable:" patch_executable_index)
  assert_not_equal("${working_directory_index}" "-1")
  assert_not_equal("${patch_executable_index}" "-1")
endfunction()

function(assert_file_content file expected_content)
  file(READ "${file}" actual_content)
  assert_equal("${actual_content}" "${expected_content}")
endfunction()

# ----------------------------------------------------------------------------------------
# Test Case 1: No patch files
# ----------------------------------------------------------------------------------------
function(run_test_no_patches)
  unset(CPM_ARGS_UNPARSED_ARGUMENTS)
  cpm_add_patches()

  assert_not_defined(CPM_ARGS_UNPARSED_ARGUMENTS)
endfunction()

# ----------------------------------------------------------------------------------------
# Test Case 2: Single patch file applies once and is skipped on the second run
# ----------------------------------------------------------------------------------------
function(run_test_single_patch)
  set(test_dir "${CMAKE_CURRENT_BINARY_DIR}/single_patch")
  set(patch_file "${test_dir}/change.patch")

  file(REMOVE_RECURSE "${test_dir}")
  file(MAKE_DIRECTORY "${test_dir}")
  file(WRITE "${test_dir}/input.txt" "old\n")
  write_patch("${patch_file}" "old" "new")

  unset(CPM_ARGS_UNPARSED_ARGUMENTS)
  cpm_add_patches("${patch_file}")
  get_patch_script(patch_script)

  run_patch_script("${patch_script}" "${test_dir}")
  assert_file_content("${test_dir}/input.txt" "new\n")

  run_patch_script("${patch_script}" "${test_dir}")
  assert_file_content("${test_dir}/input.txt" "new\n")

  file(REMOVE_RECURSE "${test_dir}/.cpm_patches")
  run_patch_script("${patch_script}" "${test_dir}")
  assert_file_content("${test_dir}/input.txt" "new\n")
  assert_not_exists("${test_dir}/input.txt.rej")
endfunction()

# ----------------------------------------------------------------------------------------
# Test Case 3: Multiple dependent patch files apply sequentially and are skipped as a set
# ----------------------------------------------------------------------------------------
function(run_test_multiple_patches)
  set(test_dir "${CMAKE_CURRENT_BINARY_DIR}/multiple_patches")
  set(patch_1 "${test_dir}/change_1.patch")
  set(patch_2 "${test_dir}/change_2.patch")

  file(REMOVE_RECURSE "${test_dir}")
  file(MAKE_DIRECTORY "${test_dir}")
  file(WRITE "${test_dir}/input.txt" "one\n")
  write_patch("${patch_1}" "one" "two")
  write_patch("${patch_2}" "two" "three")

  unset(CPM_ARGS_UNPARSED_ARGUMENTS)
  cpm_add_patches("${patch_1}" "${patch_2}")
  get_patch_script(patch_script)

  run_patch_script("${patch_script}" "${test_dir}")
  assert_file_content("${test_dir}/input.txt" "three\n")

  run_patch_script("${patch_script}" "${test_dir}")
  assert_file_content("${test_dir}/input.txt" "three\n")
endfunction()

# ----------------------------------------------------------------------------------------
# Test Case 4: Patch file paths may contain spaces
# ----------------------------------------------------------------------------------------
function(run_test_patch_path_with_spaces)
  set(test_dir "${CMAKE_CURRENT_BINARY_DIR}/patch path with spaces")
  set(patch_dir "${CMAKE_CURRENT_BINARY_DIR}/patch files with spaces")
  set(patch_file "${patch_dir}/change with spaces.patch")

  file(REMOVE_RECURSE "${test_dir}" "${patch_dir}")
  file(MAKE_DIRECTORY "${test_dir}" "${patch_dir}")
  file(WRITE "${test_dir}/input.txt" "old\n")
  write_patch("${patch_file}" "old" "new")

  unset(CPM_ARGS_UNPARSED_ARGUMENTS)
  cpm_add_patches("${patch_file}")
  get_patch_script(patch_script)

  run_patch_script("${patch_script}" "${test_dir}")
  assert_file_content("${test_dir}/input.txt" "new\n")
endfunction()

# ----------------------------------------------------------------------------------------
# Test Case 5: Edited patch files produce a new patch set
# ----------------------------------------------------------------------------------------
function(run_test_patch_file_content_change)
  set(test_dir "${CMAKE_CURRENT_BINARY_DIR}/changed_patch_file")
  set(patch_file "${test_dir}/change.patch")

  file(REMOVE_RECURSE "${test_dir}")
  file(MAKE_DIRECTORY "${test_dir}")
  file(WRITE "${test_dir}/input.txt" "old\n")
  write_patch("${patch_file}" "old" "new")

  unset(CPM_ARGS_UNPARSED_ARGUMENTS)
  cpm_add_patches("${patch_file}")
  get_patch_script(initial_patch_script)

  run_patch_script("${initial_patch_script}" "${test_dir}")
  assert_file_content("${test_dir}/input.txt" "new\n")

  write_patch("${patch_file}" "new" "newer")

  unset(CPM_ARGS_UNPARSED_ARGUMENTS)
  cpm_add_patches("${patch_file}")
  get_patch_script(updated_patch_script)

  assert_not_equal("${initial_patch_script}" "${updated_patch_script}")

  run_patch_script("${updated_patch_script}" "${test_dir}")
  assert_file_content("${test_dir}/input.txt" "newer\n")
endfunction()

# ----------------------------------------------------------------------------------------
# Test Case 6: Failed patch files do not write a stamp
# ----------------------------------------------------------------------------------------
function(run_test_failed_patch_does_not_write_stamp)
  set(test_dir "${CMAKE_CURRENT_BINARY_DIR}/failed_patch")
  set(patch_file "${test_dir}/change.patch")

  file(REMOVE_RECURSE "${test_dir}")
  file(MAKE_DIRECTORY "${test_dir}")
  file(WRITE "${test_dir}/input.txt" "current\n")
  write_patch("${patch_file}" "missing" "new")

  unset(CPM_ARGS_UNPARSED_ARGUMENTS)
  cpm_add_patches("${patch_file}")
  get_patch_script(patch_script)

  run_patch_script_expect_failure("${patch_script}" "${test_dir}")
  assert_not_exists("${test_dir}/.cpm_patches")
  assert_not_exists("${test_dir}/input.txt.rej")
endfunction()

# ----------------------------------------------------------------------------------------
# Test Case 7: Patch scripts work without dry-run support (forced NO)
# ----------------------------------------------------------------------------------------
function(run_test_patch_without_dry_run_support)
  set(test_dir "${CMAKE_CURRENT_BINARY_DIR}/patch_without_dry_run")
  set(patch_file "${test_dir}/change.patch")
  set(patch_script "${CMAKE_BINARY_DIR}/CPM_scripts/cpm_apply_patches_no_dry_run_test.cmake")

  find_program(PATCH_EXECUTABLE patch REQUIRED)

  file(REMOVE_RECURSE "${test_dir}")
  file(MAKE_DIRECTORY "${test_dir}")
  file(WRITE "${test_dir}/input.txt" "old\n")
  write_patch("${patch_file}" "old" "new")

  file(MAKE_DIRECTORY "${CMAKE_BINARY_DIR}/CPM_scripts")
  cpm_write_apply_patches_script(
    "${patch_script}" "${PATCH_EXECUTABLE}" NO "no_dry_run_test" "${patch_file}"
  )

  run_patch_script("${patch_script}" "${test_dir}")
  assert_file_content("${test_dir}/input.txt" "new\n")

  file(REMOVE_RECURSE "${test_dir}/.cpm_patches")
  run_patch_script("${patch_script}" "${test_dir}")
  assert_file_content("${test_dir}/input.txt" "new\n")
  assert_not_exists("${test_dir}/input.txt.rej")
endfunction()

# ----------------------------------------------------------------------------------------
# Test Case 8: Patch scripts work with dry-run support (forced YES)
# Only runs on systems where --dry-run is supported (skipped on BSD/macOS patch).
# ----------------------------------------------------------------------------------------
function(run_test_patch_with_dry_run_support)
  set(test_dir "${CMAKE_CURRENT_BINARY_DIR}/patch_with_dry_run")
  set(patch_file "${test_dir}/change.patch")
  set(patch_script "${CMAKE_BINARY_DIR}/CPM_scripts/cpm_apply_patches_dry_run_test.cmake")

  find_program(PATCH_EXECUTABLE patch REQUIRED)

  file(REMOVE_RECURSE "${test_dir}")
  file(MAKE_DIRECTORY "${test_dir}")
  file(WRITE "${test_dir}/input.txt" "old\n")
  write_patch("${patch_file}" "old" "new")

  file(MAKE_DIRECTORY "${CMAKE_BINARY_DIR}/CPM_scripts")
  cpm_write_apply_patches_script(
    "${patch_script}" "${PATCH_EXECUTABLE}" YES "dry_run_test" "${patch_file}"
  )

  run_patch_script("${patch_script}" "${test_dir}")
  assert_file_content("${test_dir}/input.txt" "new\n")

  run_patch_script("${patch_script}" "${test_dir}")
  assert_file_content("${test_dir}/input.txt" "new\n")

  file(REMOVE_RECURSE "${test_dir}/.cpm_patches")
  run_patch_script("${patch_script}" "${test_dir}")
  assert_file_content("${test_dir}/input.txt" "new\n")
endfunction()

function(cleanup_patch_test_files)
  file(REMOVE_RECURSE "${CMAKE_CURRENT_BINARY_DIR}/single_patch")
  file(REMOVE_RECURSE "${CMAKE_CURRENT_BINARY_DIR}/multiple_patches")
  file(REMOVE_RECURSE "${CMAKE_CURRENT_BINARY_DIR}/patch path with spaces")
  file(REMOVE_RECURSE "${CMAKE_CURRENT_BINARY_DIR}/patch files with spaces")
  file(REMOVE_RECURSE "${CMAKE_CURRENT_BINARY_DIR}/changed_patch_file")
  file(REMOVE_RECURSE "${CMAKE_CURRENT_BINARY_DIR}/failed_patch")
  file(REMOVE_RECURSE "${CMAKE_CURRENT_BINARY_DIR}/patch_without_dry_run")
  file(REMOVE_RECURSE "${CMAKE_CURRENT_BINARY_DIR}/patch_with_dry_run")
  file(REMOVE_RECURSE "${CMAKE_BINARY_DIR}/CPM_scripts")
endfunction()

run_test_no_patches()
run_test_single_patch()
run_test_multiple_patches()
run_test_patch_path_with_spaces()
run_test_patch_file_content_change()
run_test_failed_patch_does_not_write_stamp()
run_test_patch_without_dry_run_support()

find_program(_cpm_patch_exe patch QUIET)
if(_cpm_patch_exe)
  cpm_patch_supports_dry_run("${_cpm_patch_exe}" _cpm_patch_dry_run)
  if(_cpm_patch_dry_run)
    run_test_patch_with_dry_run_support()
  endif()
endif()

cleanup_patch_test_files()
