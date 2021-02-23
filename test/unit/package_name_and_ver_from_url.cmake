cmake_minimum_required(VERSION 3.14 FATAL_ERROR)

include(${CPM_PATH}/CPM.cmake)
include(${CPM_PATH}/testing.cmake)

cpm_package_name_and_ver_from_url("https://example.com/coolpack-1.2.3.zip" name ver)
assert_equal("coolpack" ${name})
assert_equal("1.2.3" ${ver})

cpm_package_name_and_ver_from_url("https://example.com/cool-pack-v1.3.tar.gz" name ver)
assert_equal("cool-pack" ${name})
assert_equal("1.3" ${ver})

cpm_package_name_and_ver_from_url(
  "https://subd.zip.com/download.php?Cool.Pack-v1.2.3rc0.tar" name ver
)
assert_equal("Cool.Pack" ${name})
assert_equal("1.2.3rc0" ${ver})

cpm_package_name_and_ver_from_url(
  "http://evil-1.2.tar.gz.com/Plan9_1.2.3a.tar.bz2?download" name ver
)
assert_equal("Plan9" ${name})
assert_equal("1.2.3a" ${ver})

cpm_package_name_and_ver_from_url(
  "http://evil-1.2.tar.gz.com/Plan_9-1.2.3a.tar.bz2?download" name ver
)
assert_equal("Plan_9" ${name})
assert_equal("1.2.3a" ${ver})

cpm_package_name_and_ver_from_url(
  "http://evil-1.2.tar.gz.com/Plan-9_1.2.3a.tar.bz2?download" name ver
)
assert_equal("Plan-9" ${name})
assert_equal("1.2.3a" ${ver})

cpm_package_name_and_ver_from_url("https://sf.com/distrib/SFLib-0.999.4.tar.gz/download" name ver)
assert_equal("SFLib" ${name})
assert_equal("0.999.4" ${ver})

cpm_package_name_and_ver_from_url("https://example.com/coolpack/v5.6.5rc44.zip" name ver)
assert_not_defined(name)
assert_equal("5.6.5rc44" ${ver})

cpm_package_name_and_ver_from_url("evil-1.3.zip.com/coolpack/release999.000beta.ZIP" name ver)
assert_not_defined(name)
assert_equal("999.000beta" ${ver})

cpm_package_name_and_ver_from_url("https://example.com/Foo55.tar.gz" name ver)
assert_equal("Foo55" ${name})
assert_not_defined(ver)

cpm_package_name_and_ver_from_url("https://example.com/foo" name ver)
assert_not_defined(name)
assert_not_defined(ver)

cpm_package_name_and_ver_from_url("example.zip.com/foo" name ver)
assert_not_defined(name)
assert_not_defined(ver)
