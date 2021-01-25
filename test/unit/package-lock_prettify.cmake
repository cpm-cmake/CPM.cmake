cmake_minimum_required(VERSION 3.14 FATAL_ERROR)

include(${CPM_PATH}/CPM.cmake)
include(${CPM_PATH}/testing.cmake)

unset(PRETTY_ARGN)
cpm_prettify_package_arguments(
  PRETTY_ARGN
  false
  NAME
  Dependency
  SOURCE_DIR
  ${CMAKE_SOURCE_DIR}/local_dependency/dependency
  UPDATE_DISCONNECTED
  ON
  TESTCUSTOMDATA
  TRUE
)
set(EXPECTED_UNCOMMENTED
    "    NAME Dependency
    SOURCE_DIR \${CMAKE_SOURCE_DIR}/local_dependency/dependency
    #(unparsed)
    UPDATE_DISCONNECTED ON TESTCUSTOMDATA TRUE
"
)
assert_equal(${PRETTY_ARGN} ${EXPECTED_UNCOMMENTED})

unset(PRETTY_ARGN)
cpm_prettify_package_arguments(
  PRETTY_ARGN
  true
  NAME
  Dependency
  SOURCE_DIR
  ${CMAKE_SOURCE_DIR}/local_dependency/dependency
  UPDATE_DISCONNECTED
  ON
  TESTCUSTOMDATA
  TRUE
)
set(EXPECTED_COMMENTED
    "#    NAME Dependency
#    SOURCE_DIR \${CMAKE_SOURCE_DIR}/local_dependency/dependency
    #(unparsed)
#    UPDATE_DISCONNECTED ON TESTCUSTOMDATA TRUE
"
)
assert_equal(${PRETTY_ARGN} ${EXPECTED_COMMENTED})
# ----
