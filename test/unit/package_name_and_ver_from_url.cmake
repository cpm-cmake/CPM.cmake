cmake_minimum_required(VERSION 3.14 FATAL_ERROR)

include(${CPM_PATH}/CPM.cmake)
include(${CPM_PATH}/testing.cmake)

cpm_package_name_and_ver_from_url("https://example.com/coolpack-1.2.3.zip" name ver)
assert_equal("coolpack" ${name})
assert_equal("1.2.3" ${ver})

cpm_package_name_and_ver_from_url("https://example.com/coolpack/v5.6.5rc0.zip" name ver)
assert_not_defined(name)
assert_equal("5.6.5rc0" ${ver})

cpm_package_name_and_ver_from_url("https://example.com/coolpack.tar.gz" name ver)
assert_equal("coolpack" ${name})
assert_not_defined(ver)

cpm_package_name_and_ver_from_url("https://example.com/foo" name ver)
assert_not_defined(name)
assert_not_defined(ver)
