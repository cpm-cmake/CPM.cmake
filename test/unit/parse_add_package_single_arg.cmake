cmake_minimum_required(VERSION 3.14 FATAL_ERROR)

include(${CPM_PATH}/CPM.cmake)
include(${CPM_PATH}/testing.cmake)

cpm_parse_add_package_single_arg("gh:cpm-cmake/CPM.cmake" args)
assert_equal("GITHUB_REPOSITORY;cpm-cmake/CPM.cmake" "${args}")

cpm_parse_add_package_single_arg("gh:cpm-cmake/CPM.cmake@1.2.3" args)
assert_equal("GITHUB_REPOSITORY;cpm-cmake/CPM.cmake;VERSION;1.2.3" "${args}")

cpm_parse_add_package_single_arg("gh:cpm-cmake/CPM.cmake#master" args)
assert_equal("GITHUB_REPOSITORY;cpm-cmake/CPM.cmake;GIT_TAG;master" "${args}")

cpm_parse_add_package_single_arg("gh:cpm-cmake/CPM.cmake@0.20.3#asdf" args)
assert_equal("GITHUB_REPOSITORY;cpm-cmake/CPM.cmake;VERSION;0.20.3;GIT_TAG;asdf" "${args}")

cpm_parse_add_package_single_arg("gh:a/b#c@d" args)
assert_equal("GITHUB_REPOSITORY;a/b;GIT_TAG;c;VERSION;d" "${args}")

cpm_parse_add_package_single_arg("gh:foo#c@d" args)
assert_equal("GITHUB_REPOSITORY;foo;GIT_TAG;c;VERSION;d" "${args}")

cpm_parse_add_package_single_arg("gh:Foo@5" args)
assert_equal("GITHUB_REPOSITORY;Foo;VERSION;5" "${args}")

cpm_parse_add_package_single_arg("gl:foo/bar" args)
assert_equal("GITLAB_REPOSITORY;foo/bar" "${args}")

cpm_parse_add_package_single_arg("gl:foo/Bar" args)
assert_equal("GITLAB_REPOSITORY;foo/Bar" "${args}")

cpm_parse_add_package_single_arg("bb:foo/bar" args)
assert_equal("BITBUCKET_REPOSITORY;foo/bar" "${args}")

cpm_parse_add_package_single_arg("bb:foo/Bar" args)
assert_equal("BITBUCKET_REPOSITORY;foo/Bar" "${args}")

cpm_parse_add_package_single_arg("https://github.com/cpm-cmake/CPM.cmake.git@0.30.5" args)
assert_equal("GIT_REPOSITORY;https://github.com/cpm-cmake/CPM.cmake.git;VERSION;0.30.5" "${args}")

cpm_parse_add_package_single_arg("git@host.xz:user/pkg.git@0.1.2" args)
assert_equal("GIT_REPOSITORY;git@host.xz:user/pkg.git;VERSION;0.1.2" "${args}")

cpm_parse_add_package_single_arg("git@host.xz:user/pkg.git@0.1.2#rc" args)
assert_equal("GIT_REPOSITORY;git@host.xz:user/pkg.git;VERSION;0.1.2;GIT_TAG;rc" "${args}")

cpm_parse_add_package_single_arg(
  "ssh://user@host.xz:123/path/to/pkg.git#fragment@1.2.3#branch" args
)
assert_equal(
  "GIT_REPOSITORY;ssh://user@host.xz:123/path/to/pkg.git#fragment;VERSION;1.2.3;GIT_TAG;branch"
  "${args}"
)

cpm_parse_add_package_single_arg("https://example.org/foo.tar.gz" args)
assert_equal("URL;https://example.org/foo.tar.gz" "${args}")

cpm_parse_add_package_single_arg("https://example.org/foo.tar.gz#baadf00d@1.2.0" args)
assert_equal("URL;https://example.org/foo.tar.gz;URL_HASH;baadf00d;VERSION;1.2.0" "${args}")

cpm_parse_add_package_single_arg("https://example.org/foo.tar.gz#MD5=baadf00d" args)
assert_equal("URL;https://example.org/foo.tar.gz;URL_HASH;MD5=baadf00d" "${args}")

cpm_parse_add_package_single_arg("https://example.org/Foo.zip#SHA3_512=1337" args)
assert_equal("URL;https://example.org/Foo.zip;URL_HASH;SHA3_512=1337" "${args}")

cpm_parse_add_package_single_arg("ftp://user:pass@server/pathname.zip#fragment#0ddb411@0" args)
assert_equal(
  "URL;ftp://user:pass@server/pathname.zip#fragment;URL_HASH;0ddb411;VERSION;0" "${args}"
)
