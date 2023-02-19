require_relative './lib'

class SystemWarnings < IntegrationTest
  def test_dependency_added_using_system
    prj = make_project from_template: 'using-adder'
    prj.create_lists_from_default_template package: <<~PACK
      # this commit has a warning in a public header
      CPMAddPackage(
        NAME Adder
        GITHUB_REPOSITORY cpm-cmake/testpack-adder
        GIT_TAG 8805960927ef97960dfc7d121760c8201e12d906
        SYSTEM YES
      )
      # all packages using `adder` will error on warnings
      target_compile_options(adder INTERFACE
        $<$<CXX_COMPILER_ID:MSVC>:/we4033 /we4716 /we4715 /WX>
        $<$<NOT:$<CXX_COMPILER_ID:MSVC>>:-Wreturn-type -Werror>
      )
    PACK

    assert_success prj.configure
    assert_success prj.build
  end

  def test_dependency_added_not_using_system
    prj = make_project from_template: 'using-adder'
    prj.create_lists_from_default_template package: <<~PACK
      # this commit has a warning in a public header
      CPMAddPackage(
        NAME Adder
        GITHUB_REPOSITORY cpm-cmake/testpack-adder
        GIT_TAG 8805960927ef97960dfc7d121760c8201e12d906
        SYSTEM NO
      )
      # all packages using `adder` will error on warnings
      target_compile_options(adder INTERFACE
        $<$<CXX_COMPILER_ID:MSVC>:/we4033 /we4716 /we4715 /WX>
        $<$<NOT:$<CXX_COMPILER_ID:MSVC>>:-Wreturn-type -Werror>
      )
    PACK

    assert_success prj.configure
    assert_failure prj.build
  end

end
