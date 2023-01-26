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

end
