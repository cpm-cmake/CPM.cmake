require_relative './lib'

class SystemWarnings < IntegrationTest
  
  def test_dependency_added_using_system
    for use_system in [true, false] do
      prj = make_project name: use_system ? "system" : "no_system", from_template: 'using-adder'
      prj.create_lists_from_default_template package: <<~PACK
        # this commit has a warning in a public header
        CPMAddPackage(
          NAME Adder
          GITHUB_REPOSITORY cpm-cmake/testpack-adder
          GIT_TAG v1.0.1-warnings
          SYSTEM #{use_system ? "YES" : "NO"}
        )
        # all packages using `adder` will error on warnings
        target_compile_options(adder INTERFACE
          $<$<CXX_COMPILER_ID:MSVC>:/Wall /WX>
          $<$<NOT:$<CXX_COMPILER_ID:MSVC>>:-Wall -Werror>
        )
      PACK

      assert_success prj.configure
      if use_system
        assert_success prj.build
      else
        assert_failure prj.build
      end
    end
  end
  
  def test_dependency_added_implicitly_using_system
    prj = make_project from_template: 'using-adder'
    prj.create_lists_from_default_template package: <<~PACK
      # this commit has a warning in a public header
      CPMAddPackage("gh:cpm-cmake/testpack-adder@1.0.1-warnings")
      # all packages using `adder` will error on warnings
      target_compile_options(adder INTERFACE
        $<$<CXX_COMPILER_ID:MSVC>:/Wall /WX>
        $<$<NOT:$<CXX_COMPILER_ID:MSVC>>:-Wall -Werror>
      )
    PACK

    assert_success prj.configure
    assert_success prj.build
  end

end
