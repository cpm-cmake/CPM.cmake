cmake_minimum_required(VERSION 3.14 FATAL_ERROR)

include(${CPM_PATH}/CPM.cmake)
include(${CPM_PATH}/testing.cmake)

cpm_package_name_from_git_uri("https://github.com/cpm-cmake/CPM.cmake.git" name)
assert_equal("CPM.cmake" ${name})

cpm_package_name_from_git_uri("ssh://user@host.xz:123/path/to/pkg.git/" name)
assert_equal("pkg" ${name})

cpm_package_name_from_git_uri("git://host.xz/path/to/pkg.git" name)
assert_equal("pkg" ${name})

cpm_package_name_from_git_uri("git@host.xz:cool-pkg.git" name)
assert_equal("cool-pkg" ${name})

cpm_package_name_from_git_uri("file:///path/to/pkg33.git" name)
assert_equal("pkg33" ${name})

cpm_package_name_from_git_uri("../local-repo/.git" name)
assert_equal("local-repo" ${name})

cpm_package_name_from_git_uri("asdf" name)
assert_not_defined(name)

cpm_package_name_from_git_uri("/something.git/stuff" name)
assert_not_defined(name)
