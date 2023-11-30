require_relative './lib'

class RelativeURLs < IntegrationTest
  def test_add_project_with_relative_urls
    prj = make_project from_template: 'using-fibadder'
    prj.create_lists_from_default_template package: 'CPMAddPackage("gh:cpm-cmake/testpack-fibadder@1.1.0-relative-urls")'
    assert_success prj.configure
    assert_success prj.build
  end
end
