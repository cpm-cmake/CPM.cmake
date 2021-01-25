cmake_minimum_required(VERSION 3.14 FATAL_ERROR)

include(${CPM_PATH}/CPM.cmake)
include(${CPM_PATH}/testing.cmake)

cpm_get_version_from_git_tag("1.2.3" VERSION)
assert_equal("1.2.3" ${VERSION})

cpm_get_version_from_git_tag("v1.2.3" VERSION)
assert_equal("1.2.3" ${VERSION})

cpm_get_version_from_git_tag("1.2.3-a" VERSION)
assert_equal("1.2.3" ${VERSION})

cpm_get_version_from_git_tag("v1.2.3-a" VERSION)
assert_equal("1.2.3" ${VERSION})
