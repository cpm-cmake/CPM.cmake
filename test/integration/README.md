# CPM.cmake Integration Tests

The integration tests of CPM.cmake are written in Ruby. They use a custom integration test framework which extends the [Test::Unit](https://www.rubydoc.info/github/test-unit/test-unit/Test/Unit) library.

They require Ruby 2.7.0 or later.

## Running tests

To run all tests from the repo root execute:

```
$ ruby test/integration/runner.rb
```

The runner will run all tests and generate a report of the exeuction.

The current working directory doesn't matter. If you are in `<repo-root>/test/integration`, you can run simply `$ ruby runner.rb`.

You can execute with `--help` (`$ ruby runner.rb --help`) to see various configuration options of the runner like running individual tests or test cases, or ones that match a regex.

The tests themselves are situated in the Ruby scripts prefixed with `test_`. `<repo-root>/test/integration/test_*`. You can also run an individual test script. For example to only run the **basics** test case, you can execute `$ ruby test_basics.rb`

The tests generate CMake scripts and execute CMake and build toolchains. By default they do this in a directory they generate in your temp path (`/tmp/cpm-test/` on Linux). You can configure the working directory of the tests with an environment variable `CPM_INTEGRATION_TEST_DIR`. For example `$ CPM_INTEGRATION_TEST_DIR=~/mycpmtest; ruby runner.rb`

## Writing tests

Writing tests makes use of the custom integration test framework in `lib.rb`. It is a relatively small extension of Ruby's Test::Unit library.

### The Gist

* Tests written in ruby scripts in this directory. The file names of tests must be prefixed with `test_`
* The file should `require_relative './lib'` to allow for individual execution (or else if will only be executable from the runner)
* A test file should contain a class which inherits from `IntegrationTest`. It can contain multiple classes, but that's typicall bad practice as it makes individual execution harder and implies dependency between the classes.
* There should be no dependency between the test scripts. Each should be executable individually and the order in which multiple ones are executed mustn't matter.
* The class should contain methods, also prefixed with `test_` which will be executed by the framework. In most cases there would be a single test method per class.
* In case there are multiple test methods, they will be executed in the order in which they are defined.
* The test methods should contain assertions which check for the expected state of things at varous points of the test's execution.

### Notable Idiosyncrasies

As an integration test framework based on a unit test framework it suffers from several idiosyncrasies. Make sure you familiarize yourself with them before writing integration tests.

**No shared instance variables between methods**

The runner will create an instance of the test class for each test method. This means that instance variables defined in a test method, *will not* be visible in another. For example:

```ruby
class MyTest < IntegrationTest
  def test_something
    @x = 123
    assert_equal 123, @x # Pass. @x is 123
  end
  def tese_something_else
    assert_equal 123, @x # Fail! @x would be nil here
  end
end
```

There are hacks around sharing Ruby state between methods, but we choose not to use them. If you want to initialize something for all test methods, use `setup`.

```ruby
class MyTest < IntegrationTest
  def setup
    @x = 123
  end
  def test_something
    assert_equal 123, @x # Pass. @x is 123 thanks to setup
  end
  def tese_something_else
    assert_equal 123, @x # Pass. @x is 123 thanks to setup
  end
end
```

**`IntegrationTest` makes use of `Test::Unit::TestCase#cleanup`**

After each test method the `cleanup` method is called thanks to Test::Unit. If you require the use of `cleanup` in your own tests, make sure you call `super` to also run `IntegrationTest#cleanup`.

```ruby
class MyTest < IntegrationTest
  def cleanup
    super
    my_cleanup
  end
  # ...
end
```

**Try to have assertions in test methods as opposed to helper methods**

Test::Unit will display a helpful message if an assertion has failed. It will also include the line of code in the test method which caused the failure. However if an assertion is not in the test method, it will display the line which calls the method in which it is. So, please try, to have most assertions in test methods (though we acknowledge that in certain cases this is not practical). For example, if you only require scopes, try using lambdas.

Instead of this:

```ruby
class MyTest < IntegrationTest
  def test_something
    do_a
    do_b
    do_c
  end
  def do_a
    # ...
  end
  def do_b
    # ...
    assert false # will display failed line as "do_b"
  end
  def do_c
    # ...
  end
end
```

...write this:

```ruby
class MyTest < IntegrationTest
  def test_something
    do_a = -> {
      # ...
    }
    do_b = -> {
      # ...
      assert false # will display failed line as "assert false"
    }
    do_c = -> {
      # ...
    }

    do_a.()
    do_b.()
    do_c.()
  end
end
```





