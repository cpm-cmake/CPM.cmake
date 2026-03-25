require_relative './lib'

class RelativeURLs < IntegrationTest
  def setup
    # relative URLs were introduced in CMake 3.27
    @relative_urls_supported = (!ENV['CMAKE_VERSION']) || (Gem::Version.new(ENV['CMAKE_VERSION']) >= Gem::Version.new('3.27'))
  end

  def test_add_project_with_relative_urls
    omit_if !@relative_urls_supported do
      prj = make_project from_template: 'using-fibadder'
      prj.create_lists_from_default_template package: 'CPMAddPackage("gh:cpm-cmake/testpack-fibadder@1.1.0-relative-urls")'
      assert_success prj.configure
      assert_success prj.build
    end
  end
end
