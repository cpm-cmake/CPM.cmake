require_relative './lib'

class SystemWarnings < IntegrationTest
  def test_add_dependency_cpm_and_fetchcontent
    prj = make_project from_template: 'using-adder'
    prj.create_lists_from_default_template package: <<~PACK
      # this commit has a warning in a public header
      CPMAddPackage("gh:cpm-cmake/testpack-adder#3046a5837ffc6a304c4a60258d39d6d2a4255548")
      # all packages using `adder` will error on warnings
      target_compile_options(adder INTERFACE "-Werror")
    PACK

    assert_success prj.configure
    # as the dependency's headers are treated as system headers, 
    # the project should build without errors 
    assert_success prj.build
  end
end
