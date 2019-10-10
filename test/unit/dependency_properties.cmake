cmake_minimum_required(VERSION 3.14 FATAL_ERROR)

include(${CPM_PATH}/CPM.cmake)
include(${CPM_PATH}/testing.cmake)

set(CPM_DRY_RUN ON)

CPMAddPackage(
  NAME A
  GIT_TAG 1.2.3
)

CPMAddPackage(
  NAME A
  VERSION 1.2.3
)

CPM_GET_PACKAGE_VERSION(A VERSION)
ASSERT_EQUAL(${VERSION} "1.2.3")

CPMAddPackage(
  NAME B
  VERSION 2.4.1
)

CPMAddPackage(
  NAME B
  GIT_TAG v2.3.1
)

CPM_GET_PACKAGE_VERSION(B VERSION)
ASSERT_EQUAL(${VERSION} "2.4.1")

CPMAddPackage(
  NAME C
  GIT_TAG v3.1.2-a
  VERSION 3.1.2
)

CPM_GET_PACKAGE_VERSION(C VERSION)
ASSERT_EQUAL(${VERSION} "3.1.2")
