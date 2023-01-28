require_relative './lib'

# Tests with source cache

class SourceCache < IntegrationTest
  def setup
    @cache_dir = File.join(cur_test_dir, 'cpmcache')
    ENV['CPM_SOURCE_CACHE'] = @cache_dir
  end

  def test_add_remove_dependency
    prj = make_project from_template: 'using-fibadder'

    ###################################
    # create
    prj.create_lists_from_default_template package: 'CPMAddPackage("gh:cpm-cmake/testpack-fibadder@1.0.0")'
    assert_success prj.configure

    @cache = prj.read_cache

    # fibadder - adder
    #          \ fibonacci - Format
    assert_equal 4, @cache.packages.size

    check_package_cache 'testpack-fibadder', '1.0.0', '6a17d24c95c44a169ff8ba173f52876a2ba3d137'
    check_package_cache 'testpack-adder', '1.0.0', '1a4c153849d8e0cf9a3a245e5f6ab6e4722d8995'
    check_package_cache 'testpack-fibonacci', '2.0', '332c789cb09b8c2f92342dfb874c82bec643daf6'
    check_package_cache 'Format.cmake', '1.0', 'c5897bd28c5032d45f7f669c8fb470790d2ae156'

    ###################################
    # add one package with a newer version
    prj.create_lists_from_default_template packages: [
      'CPMAddPackage("gh:cpm-cmake/testpack-adder@1.0.1")',
      'CPMAddPackage("gh:cpm-cmake/testpack-fibadder@1.0.0")',
    ]
    assert_success prj.configure

    @cache = prj.read_cache
    assert_equal 4, @cache.packages.size

    check_package_cache 'testpack-fibadder', '1.0.0', '6a17d24c95c44a169ff8ba173f52876a2ba3d137'
    check_package_cache 'testpack-adder', '1.0.1', '84eb33c1b8db880083cefc2adf4dc3f04778cd44'
    check_package_cache 'testpack-fibonacci', '2.0', '332c789cb09b8c2f92342dfb874c82bec643daf6'
    check_package_cache 'Format.cmake', '1.0', 'c5897bd28c5032d45f7f669c8fb470790d2ae156'
  end

  def test_second_project
    prj = make_project from_template: 'using-fibadder'
    prj.create_lists_from_default_template package: 'CPMAddPackage("gh:cpm-cmake/testpack-fibadder@1.1.0")'
    assert_success prj.configure

    @cache = prj.read_cache

    # fibadder - adder
    #          \ fibonacci - Format
    assert_equal 4, @cache.packages.size

    check_package_cache 'testpack-fibadder', '1.1.0', '603d79d88d7230cc749460a0f476df862aa70ead'
    check_package_cache 'testpack-adder', '1.0.1', '84eb33c1b8db880083cefc2adf4dc3f04778cd44'
    check_package_cache 'testpack-fibonacci', '2.0', '332c789cb09b8c2f92342dfb874c82bec643daf6'
    check_package_cache 'Format.cmake', '1.0', 'c5897bd28c5032d45f7f669c8fb470790d2ae156'
  end

  def test_cache_dir_contents
    num_subdirs = -> (name) { Dir["#{File.join(@cache_dir, name.downcase)}/*/"].size }
    assert_equal 2, num_subdirs.('testpack-fibadder')
    assert_equal 2, num_subdirs.('testpack-adder')
    assert_equal 1, num_subdirs.('testpack-fibonacci')
    assert_equal 1, num_subdirs.('Format.cmake')
  end

  def check_package_cache(name, ver, dir_sha1)
    package = @cache.packages[name]
    assert_not_nil package, name
    assert_equal ver, package.ver
    expected_parent_dir = File.join(@cache_dir, name.downcase)
    assert package.src_dir.start_with?(expected_parent_dir), "#{package.src_dir} must be in #{expected_parent_dir}"
    assert_equal dir_sha1, File.basename(package.src_dir)
  end
end
