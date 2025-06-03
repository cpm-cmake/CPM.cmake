cmake_minimum_required(VERSION 3.14 FATAL_ERROR)

set(CPM_DONT_CREATE_PACKAGE_LOCK TRUE)
include(${CPM_PATH}/CPM.cmake)
include(${CPM_PATH}/testing.cmake)

# cmake-format: off
cpm_prettify_package_arguments(PRETTY_ARGN false
  NAME Dependency
  SOURCE_DIR ${CMAKE_SOURCE_DIR}/local_dependency/dependency
  UPDATE_DISCONNECTED ON
  TESTCUSTOMDATA TRUE
)
# cmake-format: on
set(EXPECTED_UNCOMMENTED
    "  NAME Dependency
  SOURCE_DIR \${CMAKE_SOURCE_DIR}/local_dependency/dependency
  UPDATE_DISCONNECTED ON TESTCUSTOMDATA TRUE
"
)
assert_equal(${PRETTY_ARGN} ${EXPECTED_UNCOMMENTED})

# cmake-format: off
cpm_prettify_package_arguments(PRETTY_ARGN true
  NAME Dependency
  SOURCE_DIR ${CMAKE_SOURCE_DIR}/local_dependency/dependency
  UPDATE_DISCONNECTED ON
  TESTCUSTOMDATA TRUE
)
# cmake-format: on
set(EXPECTED_COMMENTED
    "#  NAME Dependency
#  SOURCE_DIR \${CMAKE_SOURCE_DIR}/local_dependency/dependency
#  UPDATE_DISCONNECTED ON TESTCUSTOMDATA TRUE
"
)
assert_equal(${PRETTY_ARGN} ${EXPECTED_COMMENTED})

cpm_prettify_package_arguments(PRETTY_ARGN true "local directory")
set(EXPECTED_COMMENTED_LOCALDIR "#  local directory
"
)
assert_equal(${PRETTY_ARGN} ${EXPECTED_COMMENTED_LOCALDIR})

# cmake-format: off
cpm_prettify_package_arguments(PRETTY_ARGN false
  NAME Dependency
  PATCHES
    patches/fix.patch
    ${CMAKE_SOURCE_DIR}/patches/absolute.patch
)
# cmake-format: on
set(EXPECTED_PATCHES
    "  NAME Dependency
  PATCHES
    \"\${CMAKE_SOURCE_DIR}/patches/fix.patch\"
    \"\${CMAKE_SOURCE_DIR}/patches/absolute.patch\"
"
)
assert_equal(${PRETTY_ARGN} ${EXPECTED_PATCHES})
