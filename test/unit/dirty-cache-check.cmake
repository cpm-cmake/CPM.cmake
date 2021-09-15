include(${CPM_PATH}/CPM.cmake)
include(${CPM_PATH}/testing.cmake)

set(baseDir "${CMAKE_CURRENT_BINARY_DIR}/test_dirty_cache")

find_package(Git REQUIRED)

function(git_do dir)
  execute_process(
    COMMAND ${GIT_EXECUTABLE} -c user.name='User' -c user.email='user@email.org' ${ARGN}
    RESULT_VARIABLE result
    OUTPUT_VARIABLE status
    OUTPUT_STRIP_TRAILING_WHITESPACE
    WORKING_DIRECTORY "${dir}"
  )
  if(result)
    message(FATAL_ERROR "git ${ARGN} fail: ${result} ${status}")
  endif()
endfunction()

file(MAKE_DIRECTORY "${baseDir}")

file(WRITE "${baseDir}/draft.txt" "this is a test")

git_do("${baseDir}" init -b main)
git_do("${baseDir}" commit --allow-empty -m "empty repo")
message(STATUS "empty repo with file")
cpm_check_git_working_dir_is_clean(${baseDir} HEAD emptygit_test)
assert_falsy(emptygit_test)

git_do("${baseDir}" add draft.txt)
git_do("${baseDir}" commit -m "test change")
git_do("${baseDir}" tag v0.0.0)
message(STATUS "commit a change")
cpm_check_git_working_dir_is_clean(${baseDir} v0.0.0 onecommit_test)
assert_truthy(onecommit_test)

file(WRITE "${baseDir}/draft.txt" "a modification")
message(STATUS "dirty repo")
cpm_check_git_working_dir_is_clean(${baseDir} v0.0.0 nonemptygit_test)
assert_falsy(nonemptygit_test)

git_do("${baseDir}" add draft.txt)
git_do("${baseDir}" commit -m "another change")
message(STATUS "repo clean")
cpm_check_git_working_dir_is_clean(${baseDir} v0.0.0 twocommit_test)
assert_falsy(twocommit_test)

file(REMOVE_RECURSE "${baseDir}")
