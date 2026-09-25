require_relative './lib'

# Tests FetchContent overriding with CPM

class FetchContentCompatibility < IntegrationTest
  def setup
    @cache_dir = File.join(cur_test_dir, 'cpmcache')
    ENV['CPM_SOURCE_CACHE'] = @cache_dir
  end

  def test_add_dependency_cpm_and_fetchcontent
    prj = make_project from_template: 'using-adder'

    prj.create_lists_from_default_template package: <<~PACK
      CPMAddPackage(
        NAME testpack-adder
        GITHUB_REPOSITORY cpm-cmake/testpack-adder
        VERSION 1.0.0
        OPTIONS "ADDER_BUILD_TESTS OFF"
      )

      # should have no effect, as we added the dependency using CPM
      FetchContent_Declare(
        testpack-adder
        GIT_REPOSITORY https://github.com/cpm-cmake/testpack-adder
        GIT_TAG v1.0.0
      )
      FetchContent_MakeAvailable(testpack-adder)
    PACK

    # configure with unpopulated cache
    assert_success prj.configure
    assert_success prj.build

    # cache is populated
    assert_true File.exist?(File.join(@cache_dir, "testpack-adder"))

    # configure with populated cache
    assert_success prj.configure
    assert_success prj.build
  end

  def test_submodules_not_cloned_when_git_submodules_empty
    prj = make_project from_template: 'using-adder'

    prj.create_lists_from_default_template package: <<~PACK
      CPMAddPackage(
        NAME testpack-adder
        GITHUB_REPOSITORY gillamkid/testpack-adder
        GIT_TAG f154cd373f2eefba715ca765892bb1c788a5f065
        GIT_SUBMODULES ""
      )

      # should have no effect, as we added the dependency using CPM
      FetchContent_Declare(
        testpack-adder
        GIT_REPOSITORY https://github.com/gillamkid/testpack-adder
        GIT_TAG f154cd373f2eefba715ca765892bb1c788a5f065
      )
      FetchContent_MakeAvailable(testpack-adder)
    PACK

    # configure with unpopulated cache
    assert_success prj.configure
    assert_success prj.build

    # check the correct repo/branch was cloned
    submodule_container_readme = File.join(prj.build_dir, '_deps', 'testpack-adder-src', 'submodules', 'README.md')
    assert_true File.exist?(submodule_container_readme)

    # check recursive cloning of submodules did NOT happen
    submodule_file = File.join(prj.build_dir, '_deps', 'testpack-adder-src', 'submodules', 'tinySubmodule', 'README.md')
    assert_false File.exist?(submodule_file)
  end

  def test_submodules_cloned_recursively_by_default
    prj = make_project from_template: 'using-adder'

    prj.create_lists_from_default_template package: <<~PACK
      CPMAddPackage(
        NAME testpack-adder
        GITHUB_REPOSITORY gillamkid/testpack-adder
        GIT_TAG f154cd373f2eefba715ca765892bb1c788a5f065
      )

      # should have no effect, as we added the dependency using CPM
      FetchContent_Declare(
        testpack-adder
        GIT_REPOSITORY https://github.com/gillamkid/testpack-adder
        GIT_TAG f154cd373f2eefba715ca765892bb1c788a5f065
      )
      FetchContent_MakeAvailable(testpack-adder)
    PACK

    # configure with unpopulated cache
    assert_success prj.configure
    assert_success prj.build

    # check the correct repo/branch was cloned
    submodule_container_readme = File.join(prj.build_dir, '_deps', 'testpack-adder-src', 'submodules', 'README.md')
    assert_true File.exist?(submodule_container_readme)

    # check recursive cloning of submodules happened
    submodule_file = File.join(prj.build_dir, '_deps', 'testpack-adder-src', 'submodules', 'tinySubmodule', 'README.md')
    assert_true File.exist?(submodule_file)
  end

end
