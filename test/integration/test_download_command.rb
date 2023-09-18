require_relative './lib'

# Tests using a multi-argumenet download command to fetch a dependency

class DownloadCommand < IntegrationTest

  def test_fetch_dependency_using_download_command
    prj = make_project from_template: 'using-adder'

    prj.create_lists_from_default_template package: <<~PACK
      set(DOWNLOAD_DIR ${CMAKE_BINARY_DIR}/_deps/testpack-adder-src)
      CPMAddPackage(
        NAME testpack-adder
        SOURCE_DIR ${DOWNLOAD_DIR}
        DOWNLOAD_COMMAND git clone --depth 1 --branch v1.0.0 https://github.com/cpm-cmake/testpack-adder.git ${DOWNLOAD_DIR}
        OPTIONS "ADDER_BUILD_TESTS OFF"
      )
    PACK

    # configure with unpopulated cache
    assert_success prj.configure
    assert_success prj.build
  end

end
