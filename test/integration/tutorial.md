# Integration Test Tutorial

Let's create an integration test which checks that CPM.cmake can make a specific package available.

First we do some boilerplate.

```ruby
require_relative './lib'

class MyTest < IntegrationTest
  # test that CPM.cmake can make https://github.com/cpm-cmake/testpack-adder/ available as a package
  def test_make_adder_available
  end
end
```

Now we have our test case class, and the single test method that we will require. Let's focus on the method's contents. The integration test framework provides us with a helper class, `Project`, which can be used for this scenario. A project has an associated pair of source and binary directories in the temporary directory and it provides methods to work with them.

We start by creating the project:

```ruby
prj = make_project
```

`make_project` is method of IntegrationTest which generates a source and a binary directory for it based on the name of our test class and test method. The project doesn't contain anything yet, so let's create some source files:

```ruby
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
```

Note the line `include("%{cpm_path}")` when creating `CMakeLists.txt`. It contains a markup `%{cpm_path}`. `Project#create_file` will see such markups and substitute them with the appropriate values (in this case the path to CPM.cmake).

Now that we have the two files we need it's time we configure our project. We can use the opportunity to assert that the configure is successful as we expect it to be.

```ruby
assert_success prj.configure
```

Now we can read the generated `CMakeCache.txt` and assert that certain values we expect are inside. `Project` provides a method for that: `read_cache`. It will return an instance of `Project::CMakeCache` which contains the data from the cache and provides additional helper functionalities. One of them is `packages`, which is a hash of the CPM.cmake packages in the cache with their versions, binary, source directories. So let's get the cache and assert that there is only one CPM.cmake package inside ant it has the version we expect.

```ruby
cache = prj.read_cache
assert_equal 1, cache.packages.size
assert_equal '1.0.0', cache.packages['testpack-adder'].ver
```

Finally let's assert that the project can be built. This would mean that CPM.cmake has made the package available to our test project and that it has the appropriate include directories and link libraries to make an executable out of `main.cpp`.

```ruby
assert_success prj.build
```

You can see the entire code for this tutorial in [tutorial.rb](tutorial.rb) in this directory.
