require_relative './lib'

# Tests using a multi-argumenet PATCHES command to fetch and modify a dependency

class DownloadCommand < IntegrationTest

  def test_fetch_dependency_using_download_command
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

end
