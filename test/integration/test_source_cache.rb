require_relative './lib'

# Tests with source cache

class SourceCache < IntegrationTest
  def setup
    super
    @cache_dir = File.join(cur_test_dir, 'cpmcache')
    ENV['CPM_SOURCE_CACHE'] = @cache_dir
  end

  def test_add_remove_dependency
    @prj = make_project 'using-fibadder'

    create_with_fibadder
  end

  def test_second_project
    # @prj = make_project 'using-fibadder'

    # create_with_newer_fibadder
  end

  def dir_subdirs(dir)
    Dir["#{dir}/*/"]
  end

  def check_package_cache(name, ver, dir_sha1)
    package = @cache.packages[name]
    assert_not_nil package, name
    assert_equal ver, package.ver
    assert package.src_dir.start_with?(@cache_dir), "#{package.src_dir} must be in #{@cache_dir}"
    assert_equal dir_sha1, File.basename(package.src_dir)
  end

  def create_with_fibadder
    @prj.create_lists_with package: 'CPMAddPackage("gh:cpm-cmake/testpack-fibadder@1.0.0")'
    assert_success @prj.configure

    @cache = @prj.read_cache

    # fibadder - adder
    #          \ fibonacci - Format
    assert_equal 4, @cache.packages.size

    check_package_cache 'testpack-fibadder', '1.0.0', '6a17d24c95c44a169ff8ba173f52876a2ba3d137'
    check_package_cache 'testpack-adder', '1.0.0', '1a4c153849d8e0cf9a3a245e5f6ab6e4722d8995'
    check_package_cache 'testpack-fibonacci', '2.0', '332c789cb09b8c2f92342dfb874c82bec643daf6'
    check_package_cache 'Format.cmake', '1.0', 'c5897bd28c5032d45f7f669c8fb470790d2ae156'
  end

  def create_with_newer_fibadder
    @prj.create_lists_with package: 'CPMAddPackage("gh:cpm-cmake/testpack-fibadder@1.1.0")'
    assert_success @prj.configure

    @cache = @prj.read_cache

    # fibadder - adder
    #          \ fibonacci - Format
    assert_equal 4, @cache.packages.size

    check_package_cache 'testpack-fibadder', '1.1.0', '6a17d24c95c44a169ff8ba173f52876a2ba3d137'
    check_package_cache 'testpack-adder', '1.0.1', '1a4c153849d8e0cf9a3a245e5f6ab6e4722d8995'
    check_package_cache 'testpack-fibonacci', '2.0', '332c789cb09b8c2f92342dfb874c82bec643daf6'
    check_package_cache 'Format.cmake', '1.0', 'c5897bd28c5032d45f7f669c8fb470790d2ae156'
  end
end
