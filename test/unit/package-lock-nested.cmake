include(${CPM_PATH}/testing.cmake)

# Regression test for nested CPMUsePackageLock calls: when a dependency also calls
# CPMUsePackageLock, the nested call must be a no-op so it does not overwrite (or redirect writes
# away from) the consuming project's lock file. Uses a throwaway local git repo so the test is
# hermetic (no network).

find_package(Git REQUIRED)

set(SCRATCH ${CMAKE_CURRENT_BINARY_DIR}/package-lock-nested)
set(REPO ${SCRATCH}/dep-repo)
set(PROJECT_DIR ${SCRATCH}/project)
set(BUILD_DIR ${SCRATCH}/build)
set(LOCK ${PROJECT_DIR}/package-lock.cmake)

execute_process(COMMAND ${CMAKE_COMMAND} -E rm -rf ${SCRATCH})
file(MAKE_DIRECTORY ${REPO})

# ---- create a dependency that itself calls CPMUsePackageLock when added ----
file(
  WRITE ${REPO}/CMakeLists.txt
  "cmake_minimum_required(VERSION 3.14)
project(Dep NONE)
include(${CPM_PATH}/CPM.cmake)
# A nested lock declaration that must not take effect (and so must never create dep-lock.cmake).
CPMUsePackageLock(dep-lock.cmake GENERATED)
"
)

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

# ---- a project that locks the dependency in GENERATED mode and pulls in the dependency ----
file(MAKE_DIRECTORY ${PROJECT_DIR})
file(
  WRITE ${PROJECT_DIR}/CMakeLists.txt
  "cmake_minimum_required(VERSION 3.14)
project(NestedLockTest NONE)
include(${CPM_PATH}/CPM.cmake)
CPMUsePackageLock(package-lock.cmake GENERATED)
CPMAddPackage(
  NAME Dep
  GIT_REPOSITORY ${REPO}
  GIT_TAG testbranch
)
"
)

execute_process(COMMAND ${CMAKE_COMMAND} -S ${PROJECT_DIR} -B ${BUILD_DIR} RESULT_VARIABLE ret)
assert_equal(${ret} "0")

# The consuming project's lock must exist and pin the dependency: the nested CPMUsePackageLock in the
# dependency must not have redirected the recording to its own lock file.
assert_exists(${LOCK})
file(READ ${LOCK} LOCK_CONTENTS)
string(FIND "${LOCK_CONTENTS}" "${EXPECTED_SHA}" sha_pos)
if(sha_pos EQUAL -1)
  assertion_failed(
    "consuming project's lock did not pin Dep to the resolved commit ${EXPECTED_SHA}; the nested "
    "CPMUsePackageLock call was not a no-op:\n${LOCK_CONTENTS}"
  )
endif()
message(STATUS "test passed: nested CPMUsePackageLock did not hijack the consuming lock")

# The nested GENERATED call must not have authored a lock in the dependency's source tree.
assert_not_exists(${BUILD_DIR}/_deps/dep-src/dep-lock.cmake)
message(STATUS "test passed: nested CPMUsePackageLock did not create its own lock file")
