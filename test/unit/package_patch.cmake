cmake_minimum_required(VERSION 3.14 FATAL_ERROR)

set(CPM_DONT_CREATE_PACKAGE_LOCK TRUE)
include(${CPM_PATH}/testing.cmake)
include(${CPM_PATH}/CPM.cmake)

set(TEST_DIR "${CMAKE_CURRENT_BINARY_DIR}/package_patch")
set(CMAKE_BINARY_DIR "${TEST_DIR}/binary")

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

# Creates a fresh `work_dir` (with an input.txt) and `patch_dir` for the test `name`.
function(new_test_dirs name content)
  file(REMOVE_RECURSE "${TEST_DIR}/${name}")
  file(MAKE_DIRECTORY "${TEST_DIR}/${name}/work" "${TEST_DIR}/${name}/patches")
  file(WRITE "${TEST_DIR}/${name}/work/input.txt" "${content}\n")
  set(work_dir
      "${TEST_DIR}/${name}/work"
      PARENT_SCOPE
  )
  set(patch_dir
      "${TEST_DIR}/${name}/patches"
      PARENT_SCOPE
  )
endfunction()

# Runs the patch command for the given patch files in `work_dir`.
function(run_patch_command work_dir result_variable)
  cpm_prepare_patches(patch_command patch_hash patch_stamps ${ARGN})
  list(REMOVE_AT patch_command 0)
  execute_process(
    COMMAND ${patch_command}
    WORKING_DIRECTORY "${work_dir}"
    RESULT_VARIABLE result
    OUTPUT_QUIET ERROR_QUIET
  )
  set(${result_variable}
      ${result}
      PARENT_SCOPE
  )
endfunction()

function(assert_input_content work_dir expected)
  file(READ "${work_dir}/input.txt" actual)
  assert_equal("${actual}" "${expected}\n")
endfunction()

# ----------------------------------------------------------------------------------------
# Test Case 1: No patch files give no command, hash or stamps
# ----------------------------------------------------------------------------------------
function(run_test_no_patches)
  cpm_prepare_patches(patch_command patch_hash patch_stamps)

  assert_empty(${patch_command})
  assert_empty(${patch_hash})
  assert_empty(${patch_stamps})
endfunction()

# ----------------------------------------------------------------------------------------
# Test Case 2: A single patch is applied once and skipped on the second run
# ----------------------------------------------------------------------------------------
function(run_test_single_patch)
  new_test_dirs(single_patch "one")
  write_patch("${patch_dir}/one.patch" "one" "two")

  run_patch_command("${work_dir}" result "${patch_dir}/one.patch")
  assert_equal("${result}" "0")
  assert_input_content("${work_dir}" "two")

  run_patch_command("${work_dir}" result "${patch_dir}/one.patch")
  assert_equal("${result}" "0")
  assert_input_content("${work_dir}" "two")
  assert_not_exists("${work_dir}/input.txt.orig")
  assert_not_exists("${work_dir}/input.txt.rej")
endfunction()

# ----------------------------------------------------------------------------------------
# Test Case 3: Several patches that depend on each other are applied in order
# ----------------------------------------------------------------------------------------
function(run_test_multiple_patches)
  new_test_dirs(multiple_patches "one")
  write_patch("${patch_dir}/one.patch" "one" "two")
  write_patch("${patch_dir}/two.patch" "two" "three")

  run_patch_command("${work_dir}" result "${patch_dir}/one.patch" "${patch_dir}/two.patch")
  assert_equal("${result}" "0")
  assert_input_content("${work_dir}" "three")

  run_patch_command("${work_dir}" result "${patch_dir}/one.patch" "${patch_dir}/two.patch")
  assert_equal("${result}" "0")
  assert_input_content("${work_dir}" "three")
endfunction()

# ----------------------------------------------------------------------------------------
# Test Case 4: Paths with spaces work
# ----------------------------------------------------------------------------------------
function(run_test_paths_with_spaces)
  new_test_dirs("paths with spaces" "one")
  write_patch("${patch_dir}/change with spaces.patch" "one" "two")

  run_patch_command("${work_dir}" result "${patch_dir}/change with spaces.patch")
  assert_equal("${result}" "0")
  assert_input_content("${work_dir}" "two")
endfunction()

# ----------------------------------------------------------------------------------------
# Test Case 5: A patch that doesn't apply fails the command and leaves no stamp
# ----------------------------------------------------------------------------------------
function(run_test_failed_patch)
  new_test_dirs(failed_patch "one")
  write_patch("${patch_dir}/conflict.patch" "unrelated" "text")

  run_patch_command("${work_dir}" result "${patch_dir}/conflict.patch")
  assert_not_equal("${result}" "0")
  assert_not_exists("${work_dir}/.cpm_patches")
endfunction()

# ----------------------------------------------------------------------------------------
# Test Case 6: Running again after a failure skips the patches that were already applied
# ----------------------------------------------------------------------------------------
function(run_test_resume_after_failure)
  new_test_dirs(resume_after_failure "one")
  write_patch("${patch_dir}/one.patch" "one" "two")
  write_patch("${patch_dir}/two.patch" "two" "three")
  write_patch("${patch_dir}/conflict.patch" "unrelated" "text")

  run_patch_command("${work_dir}" result "${patch_dir}/one.patch" "${patch_dir}/conflict.patch")
  assert_not_equal("${result}" "0")
  assert_input_content("${work_dir}" "two")

  run_patch_command("${work_dir}" result "${patch_dir}/one.patch" "${patch_dir}/two.patch")
  assert_equal("${result}" "0")
  assert_input_content("${work_dir}" "three")
endfunction()

# ----------------------------------------------------------------------------------------
# Test Case 7: The stamps from cpm_prepare_patches are the ones the command creates
# ----------------------------------------------------------------------------------------
function(run_test_stamps)
  new_test_dirs(stamps "one")
  write_patch("${patch_dir}/one.patch" "one" "two")

  cpm_prepare_patches(patch_command patch_hash patch_stamps "${patch_dir}/one.patch")
  list(LENGTH patch_stamps stamp_count)
  assert_equal("${stamp_count}" "1")

  run_patch_command("${work_dir}" result "${patch_dir}/one.patch")
  assert_exists("${work_dir}/${patch_stamps}")
endfunction()

# ----------------------------------------------------------------------------------------
# Test Case 8: The hash only depends on the patch contents and their order
# ----------------------------------------------------------------------------------------
function(run_test_patch_hash)
  new_test_dirs(patch_hash "one")
  write_patch("${patch_dir}/one.patch" "one" "two")
  write_patch("${patch_dir}/two.patch" "two" "three")
  write_patch("${patch_dir}/copy/one.patch" "one" "two")

  cpm_prepare_patches(command hash stamps "${patch_dir}/one.patch" "${patch_dir}/two.patch")

  set(CMAKE_BINARY_DIR "${TEST_DIR}/other_binary")
  cpm_prepare_patches(
    command other_binary_hash stamps "${patch_dir}/one.patch" "${patch_dir}/two.patch"
  )
  assert_equal("${hash}" "${other_binary_hash}")

  cpm_prepare_patches(
    command copied_hash stamps "${patch_dir}/copy/one.patch" "${patch_dir}/two.patch"
  )
  assert_equal("${hash}" "${copied_hash}")

  cpm_prepare_patches(
    command reordered_hash stamps "${patch_dir}/two.patch" "${patch_dir}/one.patch"
  )
  assert_not_equal("${hash}" "${reordered_hash}")

  write_patch("${patch_dir}/copy/one.patch" "one" "other")
  cpm_prepare_patches(
    command edited_hash stamps "${patch_dir}/copy/one.patch" "${patch_dir}/two.patch"
  )
  assert_not_equal("${hash}" "${edited_hash}")
endfunction()

function(cleanup_patch_test_files)
  file(REMOVE_RECURSE "${TEST_DIR}")
endfunction()

cleanup_patch_test_files()
run_test_no_patches()
run_test_single_patch()
run_test_multiple_patches()
run_test_paths_with_spaces()
run_test_failed_patch()
run_test_resume_after_failure()
run_test_stamps()
run_test_patch_hash()
cleanup_patch_test_files()
