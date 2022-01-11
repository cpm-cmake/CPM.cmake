require './lib'

class Simple < IntegrationTest
  def get_adder_data(cache)
    [
      cache['CPM_PACKAGE_testpack-adder_VERSION'].val,
      cache['CPM_PACKAGE_testpack-adder_SOURCE_DIR'].val,
      cache['CPM_PACKAGE_testpack-adder_BINARY_DIR'].val,
    ]
  end

  def test_basics
    prj = make_project 'using-adder'

    prj.create_lists_with package: 'CPMAddPackage("gh:cpm-cmake/testpack-adder#cad1cd4b4cdf957c5b59e30bc9a1dd200dbfc716")'
    cfg_result = prj.configure

    assert cfg_result.status.success?

    cache = prj.read_cache

    assert_equal 'testpack-adder', cache['CPM_PACKAGES'].val

    ver, src, bin = get_adder_data cache

    assert_equal ver, '0'
    assert File.directory? src
    assert File.directory? bin

    adder_ver_file = File.join(src, 'version')
    assert File.file? adder_ver_file
    assert_equal 'initial', File.read(adder_ver_file).strip

    # reconfigure with new version
    prj.create_lists_with package: 'CPMAddPackage("gh:cpm-cmake/testpack-adder@1.0.0")'
    cfg_result = prj.configure

    cache_new = prj.read_cache
    ver, src, bin = get_adder_data cache_new

    assert_equal '1.0.0', ver

    # dir shouldn't have changed
    assert_equal File.dirname(adder_ver_file), src

    assert_equal '1.0.0', File.read(adder_ver_file).strip
  end
end
