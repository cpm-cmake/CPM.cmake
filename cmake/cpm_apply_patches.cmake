# Auto-generated patch application script
separate_arguments(PATCH_FILES)

foreach(patch_file IN LISTS PATCH_FILES)
  message(STATUS "Checking patch: ${patch_file}")

  execute_process(
    COMMAND "${PATCH_EXECUTABLE}" --dry-run -p1
    INPUT_FILE "${patch_file}"
    RESULT_VARIABLE dry_run_result
    OUTPUT_VARIABLE dry_out
    ERROR_VARIABLE dry_err
  )

  if(dry_run_result EQUAL 0)
    message(STATUS "Applying patch: ${patch_file}")
    execute_process(
      COMMAND "${PATCH_EXECUTABLE}" -p1
      INPUT_FILE "${patch_file}"
      RESULT_VARIABLE apply_result
      OUTPUT_VARIABLE apply_out
      ERROR_VARIABLE apply_err
    )
    if(apply_result EQUAL 0)
      message(STATUS "Applied patch: ${patch_file}")
    else()
      message(FATAL_ERROR "Patch failed: ${patch_file}\n${apply_err}")
    endif()
  else()
    execute_process(
      COMMAND "${PATCH_EXECUTABLE}" --dry-run -p1 --reverse
      INPUT_FILE "${patch_file}"
      RESULT_VARIABLE reverse_result
      OUTPUT_VARIABLE reverse_out
      ERROR_VARIABLE reverse_err
    )
    if(reverse_result EQUAL 0)
      message(STATUS "Patch already applied: ${patch_file}")
    else()
      message(
        FATAL_ERROR "Patch cannot be applied and is not already applied: ${patch_file}\n${dry_err}"
      )
    endif()
  endif()
endforeach()
