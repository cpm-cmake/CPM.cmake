require_relative './lib'

class RemoveSourceDir < IntegrationTest
  def test_remove_source_dir
    prj = make_project from_template: 'using-adder'

    prj.create_lists_from_default_template package: <<~PACK
      CPMAddPackage(
        NAME testpack-adder
        GITHUB_REPOSITORY cpm-cmake/testpack-adder
        VERSION 1.0.0
        OPTIONS "ADDER_BUILD_TESTS OFF"
        SOURCE_DIR testpack-adder
      )
    PACK

    # configure and build
    assert_success prj.configure
    assert_success prj.build

    # source_dir is populated
    assert_true File.exist?(File.join(prj.bin_dir, 'testpack-adder'))

    # source_dir is deleted by user
    FileUtils.remove_dir(File.join(prj.bin_dir, 'testpack-adder'), true)
    assert_false File.exist?(File.join(prj.bin_dir, 'testpack-adder'))

    # configure and build with missing source_dir to fetch new content
    assert_success prj.configure
    assert_success prj.build

    # source_dir is populated
    assert_true File.exist?(File.join(prj.bin_dir, 'testpack-adder'))
  end

end
