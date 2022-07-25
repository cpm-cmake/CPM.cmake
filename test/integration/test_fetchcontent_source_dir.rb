require_relative './lib'

# Tests FetchContent overriding with CPM

class FetchContentSourceDir < IntegrationTest
  def setup
    @cache_dir = File.join(cur_test_dir, 'cpmcache')
    ENV['CPM_SOURCE_CACHE'] = @cache_dir
  end

  def test_add_dependency_cpm_and_fetchcontent
    prj = make_project 'using-adder'
    
    prj.create_lists_from_default_template package: <<~PACK
      CPMAddPackage(
        NAME testpack-adder
        GITHUB_REPOSITORY cpm-cmake/testpack-adder
        VERSION 1.0.0
        OPTIONS "ADDER_BUILD_TESTS OFF"
        SOURCE_DIR testpack-adder
      )
    PACK

    # configure with unpopulated cache
    assert_success prj.configure
    assert_success prj.build

    # source_dir is populated
    assert_true File.exist?(File.join(prj.bin_dir, 'testpack-adder'))

    # source_dir is deleted by user
    FileUtils.remove_dir(File.join(prj.bin_dir, 'testpack-adder'), true)
    assert_false File.exist?(File.join(prj.bin_dir, 'testpack-adder'))

    # configure with missing source_dir to fetch content
    assert_success prj.configure
    assert_success prj.build

    # source_dir is populated
    assert_true File.exist?(File.join(prj.bin_dir, 'testpack-adder'))
  end

end
