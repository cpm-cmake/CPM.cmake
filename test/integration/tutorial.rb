# This file is intentionally not prefixed with test_
# It is a tutorial for making integration tests and is not to be run from the runner
require_relative './lib'

class Tutorial < IntegrationTest
  # test that CPM.cmake can make https://github.com/cpm-cmake/testpack-adder/ available as a package
  def test_make_adder_available
    prj = make_project

    prj.create_file 'main.cpp', <<~SRC
      #include <iostream>
      #include <adder/adder.hpp>
      int main() {
          std::cout << adder::add(1, 2) << '\\n';
          return 0;
      }
    SRC

    prj.create_file 'CMakeLists.txt', <<~SRC
      cmake_minimum_required(VERSION 3.14 FATAL_ERROR)
      project(using-adder)
      set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)
      include("%{cpm_path}")
      CPMAddPackage("gh:cpm-cmake/testpack-adder@1.0.0")
      add_executable(using-adder main.cpp)
      target_link_libraries(using-adder adder)
    SRC

    assert_success prj.configure

    cache = prj.read_cache
    assert_equal 1, cache.packages.size
    assert_equal '1.0.0', cache.packages['testpack-adder'].ver

    assert_success prj.build
  end
end
