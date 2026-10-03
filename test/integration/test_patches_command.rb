require_relative './lib'

# Tests using a multi-argumenet PATCHES command to fetch and modify a dependency

class PatchesCommand < IntegrationTest

  def test_patches_with_download_command
    prj = make_project from_template: 'using-patch-adder'

    prj.create_lists_from_default_template package: <<~PACK
      set(DOWNLOAD_DIR ${CMAKE_BINARY_DIR}/_deps/testpack-adder-src)
      CPMAddPackage(
        NAME testpack-adder
        DOWNLOAD_COMMAND git clone --depth 1 --branch v1.0.0 https://github.com/cpm-cmake/testpack-adder.git ${DOWNLOAD_DIR}
        OPTIONS "ADDER_BUILD_TESTS OFF" "ADDER_BUILD_EXAMPLES OFF"
        PATCHES
          patches/001-test_patches_command.patch
          patches/002-test_patches_command.patch
      )
    PACK

    # configure with unpopulated cache
    assert_success prj.configure
    assert_success prj.build
  end

  # Without CPM_SOURCE_CACHE, a reconfigure must not try to apply the patches a second time
  # https://github.com/cpm-cmake/CPM.cmake/issues/577
  def test_reconfigure_with_patches
    prj = make_project from_template: 'using-patch-adder'
    prj.create_lists_from_default_template package: git_package_with_patches

    assert_success prj.configure
    assert_success prj.configure
    assert_success prj.build
  end

  # Changing the patches must re-fetch the dependency and apply the new set to clean sources
  def test_changed_patches_are_applied_to_clean_sources
    prj = make_project from_template: 'using-patch-adder'
    prj.create_lists_from_default_template package: git_package_with_patches
    assert_success prj.configure

    prj.create_lists_from_default_template package: git_package_with_patches(
      'patches/001-test_patches_command.patch'
    )
    assert_success prj.configure

    src_dir = File.join(prj.bin_dir, '_deps', 'testpack-adder-src', 'code', 'adder')
    assert_match(/namespace patched/, File.read(File.join(src_dir, 'adder.hpp')))
    assert_match(/namespace adder/, File.read(File.join(src_dir, 'adder.cpp')))
  end

  # A patch that does not apply must still be an error after a successful configure
  def test_bad_patch_fails_after_reconfigure
    prj = make_project from_template: 'using-patch-adder'
    prj.create_lists_from_default_template package: git_package_with_patches
    assert_success prj.configure

    prj.create_file 'patches/002-test_patches_command.patch', <<~PATCH
      --- a/code/adder/adder.cpp
      +++ b/code/adder/adder.cpp
      @@ -1,1 +1,1 @@
      -this line does not exist
      +neither does this one
    PATCH
    assert_failure prj.configure
  end

  def git_package_with_patches(*patches)
    patches = %w(
      patches/001-test_patches_command.patch
      patches/002-test_patches_command.patch
    ) if patches.empty?
    <<~PACK
      CPMAddPackage(
        NAME testpack-adder
        GIT_REPOSITORY https://github.com/cpm-cmake/testpack-adder
        GIT_TAG v1.0.0
        OPTIONS "ADDER_BUILD_TESTS OFF" "ADDER_BUILD_EXAMPLES OFF"
        PATCHES
          #{patches.join("\n    ")}
      )
    PACK
  end

end
