include(${CPM_PATH}/testing.cmake)

# Regression test for nested CPM usage with a GENERATED lock:
#
# 1. When a dependency also calls CPMUsePackageLock, the nested call must be a no-op so it does not
#    overwrite (or redirect writes away from) the consuming project's lock file.
# 2. A package added from within a dependency must still land in the consuming project's lock, pinned
#    and annotated with the package that added it (the relationship information needed to derive an
#    SBOM from the lock).
#
# Uses throwaway local git repos so the test is hermetic (no network).

find_package(Git REQUIRED)

set(SCRATCH ${CMAKE_CURRENT_BINARY_DIR}/package-lock-nested)
set(REPO ${SCRATCH}/dep-repo)
set(GRAND_REPO ${SCRATCH}/grand-dep-repo)
set(PROJECT_DIR ${SCRATCH}/project)
set(BUILD_DIR ${SCRATCH}/build)
set(LOCK ${PROJECT_DIR}/package-lock.cmake)

execute_process(COMMAND ${CMAKE_COMMAND} -E rm -rf ${SCRATCH})

function(git dir)
  execute_process(
    COMMAND ${GIT_EXECUTABLE} ${ARGN}
    WORKING_DIRECTORY ${dir}
    RESULT_VARIABLE git_result
    OUTPUT_QUIET ERROR_QUIET
  )
  assert_equal(${git_result} "0")
endfunction()

function(create_repo_on_testbranch dir sha_out)
  git(${dir} init)
  git(${dir} config user.email "test@example.com")
  git(${dir} config user.name "CPM Test")
  git(${dir} add -A)
  git(${dir} commit -m "initial commit")
  git(${dir} branch -M testbranch)
  execute_process(
    COMMAND ${GIT_EXECUTABLE} rev-parse HEAD
    WORKING_DIRECTORY ${dir}
    OUTPUT_VARIABLE sha
    OUTPUT_STRIP_TRAILING_WHITESPACE
  )
  set(${sha_out}
      "${sha}"
      PARENT_SCOPE
  )
endfunction()

# ---- create a leaf dependency that the mid-level dependency will add via CPM ----
file(MAKE_DIRECTORY ${GRAND_REPO})
file(WRITE ${GRAND_REPO}/VERSION "1.0")
create_repo_on_testbranch(${GRAND_REPO} GRAND_EXPECTED_SHA)

# ---- create a dependency that itself calls CPMUsePackageLock and adds a package when added ----
file(MAKE_DIRECTORY ${REPO})
file(
  WRITE ${REPO}/CMakeLists.txt
  "cmake_minimum_required(VERSION 3.14)
project(Dep NONE)
include(${CPM_PATH}/CPM.cmake)
# A nested lock declaration that must not take effect (and so must never create dep-lock.cmake).
CPMUsePackageLock(dep-lock.cmake GENERATED)
CPMAddPackage(
  NAME GrandDep
  GIT_REPOSITORY ${GRAND_REPO}
  GIT_TAG testbranch
  DOWNLOAD_ONLY YES
)
"
)
create_repo_on_testbranch(${REPO} EXPECTED_SHA)

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

# The consuming project's lock must exist and pin the dependency: the nested CPMUsePackageLock in
# the dependency must not have redirected the recording to its own lock file.
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

# The package added from within Dep must be recorded in the consuming lock, pinned to its resolved
# commit and attributed to Dep, so dependency relationships can be reconstructed (e.g. for SBOMs).
string(FIND "${LOCK_CONTENTS}" "${GRAND_EXPECTED_SHA}" grand_sha_pos)
if(grand_sha_pos EQUAL -1)
  assertion_failed(
    "lock did not pin the transitively added GrandDep to ${GRAND_EXPECTED_SHA}:\n${LOCK_CONTENTS}"
  )
endif()
string(FIND "${LOCK_CONTENTS}" "# GrandDep (transitive dependency of Dep)" relationship_pos)
if(relationship_pos EQUAL -1)
  assertion_failed(
    "lock did not attribute GrandDep to the package that added it:\n${LOCK_CONTENTS}"
  )
endif()
message(STATUS "test passed: transitively added package is pinned and attributed to its parent")

# The directly added dependency must not carry a relationship annotation.
string(FIND "${LOCK_CONTENTS}" "# Dep\n" direct_pos)
if(direct_pos EQUAL -1)
  assertion_failed(
    "lock entry for the directly added Dep is missing or unexpectedly annotated:\n${LOCK_CONTENTS}"
  )
endif()
message(STATUS "test passed: directly added package has no relationship annotation")
