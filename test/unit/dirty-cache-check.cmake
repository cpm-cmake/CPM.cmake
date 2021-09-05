include(${CPM_PATH}/CPM.cmake)
include(${CPM_PATH}/testing.cmake)

set(baseDir "${CMAKE_CURRENT_BINARY_DIR}/test_dirty_cache")
set(childDir "${baseDir}/edgecase")

find_package(Git REQUIRED)

function(git_do dir)
  execute_process(
    COMMAND ${GIT_EXECUTABLE}  -c user.name='User' -c user.email='user@email.org' ${ARGN}
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
message(STATUS "no git, a file")
cpm_check_working_dir_is_clean(${baseDir} nogit_test)
assert_truthy(nogit_test)

git_do("${baseDir}" init -b main)
message(STATUS "empty repo with file")
cpm_check_working_dir_is_clean(${baseDir} emptygit_test)
assert_falsy(emptygit_test)

git_do("${baseDir}" add draft.txt)
git_do("${baseDir}" commit -m "test change")
message(STATUS "commit a change")
cpm_check_working_dir_is_clean(${baseDir} onecommit_test)
assert_truthy(onecommit_test)

file(WRITE "${baseDir}/draft.txt" "a modification")
message(STATUS "dirty repo")
cpm_check_working_dir_is_clean(${baseDir} nonemptygit_test)
assert_falsy(nonemptygit_test)

git_do("${baseDir}" add draft.txt)
git_do("${baseDir}" commit -m "another change")
message(STATUS "repo clean")
cpm_check_working_dir_is_clean(${baseDir} twocommit_test)
assert_truthy(twocommit_test)

file(MAKE_DIRECTORY "${childDir}")
file(WRITE "${childDir}/draft.txt" "this in another test")
message(STATUS "a sub dir")
cpm_check_working_dir_is_clean(${childDir} edgecase_test)
assert_truthy(edgecase_test)


file(REMOVE_RECURSE "${baseDir}")
