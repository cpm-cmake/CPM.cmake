cmake_minimum_required(VERSION 3.14 FATAL_ERROR)

include(${CPM_PATH}/CPM.cmake)
include(${CPM_PATH}/testing.cmake)

cpm_parse_add_package_single_arg("gh:cpm-cmake/CPM.cmake" args)
assert_equal("GITHUB_REPOSITORY;https://github.com/cpm-cmake/CPM.cmake.git" "${args}")

cpm_parse_add_package_single_arg("gh:cpm-cmake/CPM.cmake@1.2.3" args)
assert_equal("GITHUB_REPOSITORY;https://github.com/cpm-cmake/CPM.cmake.git;VERSION;1.2.3" "${args}")

cpm_parse_add_package_single_arg("gh:cpm-cmake/CPM.cmake#master" args)
assert_equal(
  "GITHUB_REPOSITORY;https://github.com/cpm-cmake/CPM.cmake.git;GIT_TAG;master" "${args}"
)

cpm_parse_add_package_single_arg("gh:cpm-cmake/CPM.cmake@0.20.3#asdf" args)
assert_equal(
  "GITHUB_REPOSITORY;https://github.com/cpm-cmake/CPM.cmake.git;VERSION;0.20.3;GIT_TAG;asdf"
  "${args}"
)

cpm_parse_add_package_single_arg("gh:a/b#c@d" args)
assert_equal("GITHUB_REPOSITORY;https://github.com/a/b.git;GIT_TAG;c;VERSION;d" "${args}")

cpm_parse_add_package_single_arg("gh:foo#c@d" args)
assert_equal("GITHUB_REPOSITORY;https://github.com/foo.git;GIT_TAG;c;VERSION;d" "${args}")

cpm_parse_add_package_single_arg("gh:Foo@5" args)
assert_equal("GITHUB_REPOSITORY;https://github.com/Foo.git;VERSION;5" "${args}")

cpm_parse_add_package_single_arg("gl:foo/bar" args)
assert_equal("GITLAB_REPOSITORY;https://gitlab.com/foo/bar.git" "${args}")

cpm_parse_add_package_single_arg("gl:foo/Bar" args)
assert_equal("GITLAB_REPOSITORY;https://gitlab.com/foo/Bar.git" "${args}")

cpm_parse_add_package_single_arg("bb:foo/bar" args)
assert_equal("BITBUCKET_REPOSITORY;https://bitbucket.org/foo/bar.git" "${args}")

cpm_parse_add_package_single_arg("bb:foo/Bar" args)
assert_equal("BITBUCKET_REPOSITORY;https://bitbucket.org/foo/Bar.git" "${args}")

cpm_parse_add_package_single_arg("https://github.com/cpm-cmake/CPM.cmake.git@0.30.5" args)
assert_equal("GIT_REPOSITORY;https://github.com/cpm-cmake/CPM.cmake.git;VERSION;0.30.5" "${args}")

cpm_parse_add_package_single_arg("git@host.xz:user/pkg.git@0.1.2" args)
assert_equal("GIT_REPOSITORY;git@host.xz:user/pkg.git;VERSION;0.1.2" "${args}")

cpm_parse_add_package_single_arg("git@host.xz:user/pkg.git@0.1.2#rc" args)
assert_equal("GIT_REPOSITORY;git@host.xz:user/pkg.git;VERSION;0.1.2;GIT_TAG;rc" "${args}")

cpmdefineurischeme(
  ALIAS
  "ir"
  LONG_NAME
  "INTERNAL_REPOS"
  URI_TYPE
  "GIT_REPOSITORY"
  URI_ROOT
  "git@company.internal.gitserver"
)

cpmdefineurischeme(
  ALIAS
  "ir2"
  LONG_NAME
  "INTERNAL_REPOS2"
  URI_TYPE
  "GIT_REPOSITORY"
  URI_ROOT
  "https://company.internal.oldGitserver"
  URI_SUFFIX
  ".gitz"
)

cpmdefineurischeme(
  ALIAS
  "af"
  LONG_NAME
  "ARTIFACTORY_PKG"
  URI_TYPE
  "URL"
  URI_ROOT
  "https://my.company.artifatory/pkgs"
)

cpm_parse_add_package_single_arg("ir:somegroup/somerepo@0.20.3#asdf" args)
assert_equal(
  "INTERNAL_REPOS;git@company.internal.gitserver/somegroup/somerepo.git;VERSION;0.20.3;GIT_TAG;asdf"
  "${args}"
)

cpm_parse_add_package_single_arg("ir2:somegroup/somerepo@0.20.3#asdf" args)
assert_equal(
  "INTERNAL_REPOS2;https://company.internal.oldGitserver/somegroup/somerepo.gitz;VERSION;0.20.3;GIT_TAG;asdf"
  "${args}"
)

cpm_parse_add_package_single_arg("af:somegroup/someitem.zip" args)
assert_equal("ARTIFACTORY_PKG;https://my.company.artifatory/pkgs/somegroup/someitem.zip" "${args}")

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
