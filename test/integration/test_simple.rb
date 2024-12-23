require_relative './lib'

class Simple < IntegrationTest
  ADDER_PACKAGE_NAME = 'testpack-adder'

  def test_update_single_package
    prj = make_project from_template: 'using-adder'
    adder_cache0 = nil
    adder_ver_file = nil

    create_with_commit_sha = -> {
      prj.create_lists_from_default_template package:
        'CPMAddPackage("gh:cpm-cmake/testpack-adder#cad1cd4b4cdf957c5b59e30bc9a1dd200dbfc716")'
      assert_success prj.configure

      cache = prj.read_cache
      assert_equal 1, cache.packages.size

      adder_cache = cache.packages[ADDER_PACKAGE_NAME]
      assert_not_nil adder_cache
      assert_equal '0', adder_cache.ver
      assert File.directory? adder_cache.src_dir
      assert File.directory? adder_cache.bin_dir

      adder_ver_file = File.join(adder_cache.src_dir, 'version')
      assert File.file? adder_ver_file
      assert_equal 'initial', File.read(adder_ver_file).strip

      # calculated adder values
      assert_equal 'ON', cache['ADDER_BUILD_EXAMPLES']
      assert_equal 'ON', cache['ADDER_BUILD_TESTS']
      assert_equal adder_cache.src_dir, cache['adder_SOURCE_DIR']
      assert_equal adder_cache.bin_dir, cache['adder_BINARY_DIR']

      # store for future comparisons
      adder_cache0 = adder_cache
    }
    update_to_version_1 = -> {
      prj.create_lists_from_default_template package:
        'CPMAddPackage("gh:cpm-cmake/testpack-adder@1.0.0")'
      assert_success prj.configure

      cache = prj.read_cache
      assert_equal 1, cache.packages.size

      adder_cache = cache.packages[ADDER_PACKAGE_NAME]
      assert_not_nil adder_cache
      assert_equal '1.0.0', adder_cache.ver

      # dirs shouldn't have changed
      assert_equal adder_cache0.src_dir, adder_cache.src_dir
      assert_equal adder_cache0.bin_dir, adder_cache.bin_dir

      assert_equal '1.0.0', File.read(adder_ver_file).strip
    }
    update_with_option_off_and_build = -> {
      prj.create_lists_from_default_template package: <<~PACK
        CPMAddPackage(
          NAME testpack-adder
          GITHUB_REPOSITORY cpm-cmake/testpack-adder
          VERSION 1.0.0
          OPTIONS "ADDER_BUILD_TESTS OFF"
        )
      PACK
      assert_success prj.configure
      assert_success prj.build

      exe_dir = File.join(prj.bin_dir, 'bin')
      assert File.directory? exe_dir

      exes = Dir[exe_dir + '/**/*'].filter {
        # on multi-configuration generators (like Visual Studio) the executables will be in bin/<Config>
        # also filter-out other artifacts like .pdb or .dsym
        !File.directory?(_1) && File.stat(_1).executable?
      }.map {
        # remove .exe extension if any (there will be one on Windows)
        File.basename(_1, '.exe')
      }.sort

      # we should end up with two executables
      # * simple - the simple example from adder
      # * using-adder - for this project
      # ...and notably no test for adder, which must be disabled from the option override from above
      assert_equal ['simple', 'using-adder'], exes
    }
    update_with_option_off_and_build_with_uri_shorthand_syntax = -> {
      prj.create_lists_from_default_template package: <<~PACK
        CPMAddPackage(
          URI gh:cpm-cmake/testpack-adder@1.0.0
          OPTIONS "ADDER_BUILD_TESTS OFF"
        )
      PACK
      assert_success prj.configure
      assert_success prj.build

      exe_dir = File.join(prj.bin_dir, 'bin')
      assert File.directory? exe_dir

      exes = Dir[exe_dir + '/**/*'].filter {
        # on multi-configuration generators (like Visual Studio) the executables will be in bin/<Config>
        # also filter-out other artifacts like .pdb or .dsym
        !File.directory?(_1) && File.stat(_1).executable?
      }.map {
        # remove .exe extension if any (there will be one on Windows)
        File.basename(_1, '.exe')
      }.sort

      # we should end up with two executables
      # * simple - the simple example from adder
      # * using-adder - for this project
      # ...and notably no test for adder, which must be disabled from the option override from above
      assert_equal ['simple', 'using-adder'], exes
    }
    update_with_option_on_and_build_with_uri_shorthand_syntax_and_exclude_from_override = -> {
      prj.create_lists_from_default_template package: <<~PACK
        CPMAddPackage(
          URI gh:cpm-cmake/testpack-adder@1.0.0
          OPTIONS "ADDER_BUILD_TESTS ON"
          EXCLUDE_FROM_ALL NO
        )
      PACK
      assert_success prj.configure
      assert_success prj.build

      exe_dir = File.join(prj.bin_dir, 'bin')
      assert File.directory? exe_dir

      exes = Dir[exe_dir + '/**/*'].filter {
        # on multi-configuration generators (like Visual Studio) the executables will be in bin/<Config>
        # also filter-out other artifacts like .pdb or .dsym
        !File.directory?(_1) && File.stat(_1).executable?
      }.map {
        # remove .exe extension if any (there will be one on Windows)
        File.basename(_1, '.exe')
      }.sort

      # we should end up with two executables
      # * simple - the simple example from adder
      # * using-adder - for this project
      # ...and notably no test for adder, which must be disabled from the option override from above
      assert_equal ['simple', 'test-adding', 'using-adder'], exes
    }


    create_with_commit_sha.()
    update_to_version_1.()
    update_with_option_off_and_build.()
    update_with_option_off_and_build_with_uri_shorthand_syntax.()
    update_with_option_on_and_build_with_uri_shorthand_syntax_and_exclude_from_override.()
  end
end
