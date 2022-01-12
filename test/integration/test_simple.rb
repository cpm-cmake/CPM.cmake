require_relative './lib'

class Simple < IntegrationTest
  P_ADDER = 'testpack-adder'

  def test_basics
    prj = make_project 'using-adder'

    prj.create_lists_with package: 'CPMAddPackage("gh:cpm-cmake/testpack-adder#cad1cd4b4cdf957c5b59e30bc9a1dd200dbfc716")'
    assert_success prj.configure

    cache = prj.read_cache
    assert_equal 1, cache.packages.size

    adder = cache.packages[P_ADDER]
    assert_not_nil adder
    assert_equal '0', adder.ver
    assert File.directory? adder.src_dir
    assert File.directory? adder.bin_dir

    adder_ver_file = File.join(adder.src_dir, 'version')
    assert File.file? adder_ver_file
    assert_equal 'initial', File.read(adder_ver_file).strip

    # reconfigure with new version
    prj.create_lists_with package: 'CPMAddPackage("gh:cpm-cmake/testpack-adder@1.0.0")'
    assert_success prj.configure

    cache = prj.read_cache
    assert_equal 1, cache.packages.size

    adder = cache.packages[P_ADDER]
    assert_not_nil adder
    assert_equal '1.0.0', adder.ver

    # dir shouldn't have changed
    assert_equal File.dirname(adder_ver_file), adder.src_dir

    assert_equal '1.0.0', File.read(adder_ver_file).strip
  end
end
