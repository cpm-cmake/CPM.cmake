include(${CPM_PATH}/testing.cmake)

# Exercises `CPMUsePackageLock(<file> GENERATED)`: the lock must be written into the source tree on
# configure (no cpm-update-package-lock step) with git packages pinned to the resolved commit. Uses
# a throwaway local git repo so the test is hermetic (no network).

find_package(Git REQUIRED)

set(SCRATCH ${CMAKE_CURRENT_BINARY_DIR}/package-lock-generated)
set(REPO ${SCRATCH}/dep-repo)
set(PROJECT_DIR ${SCRATCH}/project)
set(BUILD_DIR ${SCRATCH}/build)
set(LOCK ${PROJECT_DIR}/package-lock.cmake)

execute_process(COMMAND ${CMAKE_COMMAND} -E rm -rf ${SCRATCH})
file(MAKE_DIRECTORY ${REPO})

# ---- create a dependency git repo with a single commit on branch `testbranch` ----
file(WRITE ${REPO}/VERSION "1.0")

function(git)
  execute_process(
    COMMAND ${GIT_EXECUTABLE} ${ARGN}
    WORKING_DIRECTORY ${REPO}
    RESULT_VARIABLE git_result
    OUTPUT_QUIET ERROR_QUIET
  )
  assert_equal(${git_result} "0")
endfunction()

git(init)
git(config user.email "test@example.com")
git(config user.name "CPM Test")
git(add -A)
git(commit -m "initial commit")
git(branch -M testbranch)

execute_process(
  COMMAND ${GIT_EXECUTABLE} rev-parse HEAD
  WORKING_DIRECTORY ${REPO}
  OUTPUT_VARIABLE EXPECTED_SHA
  OUTPUT_STRIP_TRAILING_WHITESPACE
)

# ---- a project that locks the dependency in GENERATED mode, declared against the branch ----
file(MAKE_DIRECTORY ${PROJECT_DIR})
file(
  WRITE ${PROJECT_DIR}/CMakeLists.txt
  "cmake_minimum_required(VERSION 3.14)
project(GeneratedLockTest NONE)
include(${CPM_PATH}/CPM.cmake)
CPMUsePackageLock(package-lock.cmake GENERATED)
CPMAddPackage(
  NAME Dep
  GIT_REPOSITORY ${REPO}
  GIT_TAG testbranch
  DOWNLOAD_ONLY YES
)
"
)

# Configure only — no `cpm-update-package-lock` target is built.
execute_process(COMMAND ${CMAKE_COMMAND} -S ${PROJECT_DIR} -B ${BUILD_DIR} RESULT_VARIABLE ret)
assert_equal(${ret} "0")

# The lock must have been authored into the source tree automatically.
assert_exists(${LOCK})

file(READ ${LOCK} LOCK_RUN1)

string(FIND "${LOCK_RUN1}" "${EXPECTED_SHA}" sha_pos)
if(sha_pos EQUAL -1)
  assertion_failed(
    "generated lock did not pin Dep to the resolved commit ${EXPECTED_SHA}:\n${LOCK_RUN1}"
  )
endif()
message(STATUS "test passed: generated lock pinned Dep to ${EXPECTED_SHA}")

string(FIND "${LOCK_RUN1}" "GIT_TAG testbranch" branch_pos)
if(NOT branch_pos EQUAL -1)
  assertion_failed("generated lock still references the moving branch instead of a commit")
endif()
message(STATUS "test passed: generated lock does not reference the moving branch")

# Reconfiguring must be idempotent: the pin is consumed and an identical lock is produced.
execute_process(COMMAND ${CMAKE_COMMAND} -S ${PROJECT_DIR} -B ${BUILD_DIR} RESULT_VARIABLE ret2)
assert_equal(${ret2} "0")
file(READ ${LOCK} LOCK_RUN2)
assert_equal("${LOCK_RUN1}" "${LOCK_RUN2}")
message(STATUS "test passed: generated lock is stable across reconfigures")
