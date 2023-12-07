# CPM.cmake Integration Tests

The integration tests of CPM.cmake are written in Ruby. They use a custom integration test framework which extends the [Test::Unit](https://www.rubydoc.info/github/test-unit/test-unit/Test/Unit) library.

They require Ruby 2.7.0 or later.

## Running tests

To run all tests from the repo root execute:

```
$ ruby test/integration/runner.rb
```

The runner will run all tests and generate a report of the execution.

The current working directory doesn't matter. If you are in `<repo-root>/test/integration`, you can run simply `$ ruby runner.rb`.

You can execute with `--help` (`$ ruby runner.rb --help`) to see various configuration options of the runner like running individual tests or test cases, or ones that match a regex.

The tests themselves are situated in the Ruby scripts prefixed with `test_`. `<repo-root>/test/integration/test_*`. You can also run an individual test script. For example to only run the **basics** test case, you can execute `$ ruby test_basics.rb`

The tests generate CMake scripts and execute CMake and build toolchains. By default they do this in a directory they generate in your temp path (`/tmp/cpm-test/` on Linux). You can configure the working directory of the tests with an environment variable `CPM_INTEGRATION_TEST_DIR`. For example `$ CPM_INTEGRATION_TEST_DIR=~/mycpmtest; ruby runner.rb`

## Writing tests

Writing tests makes use of the custom integration test framework in `lib.rb`. It is a relatively small extension of Ruby's Test::Unit library.

### The Gist

* Tests cases are Ruby scripts in this directory. The file names must be prefixed with `test_`
* The script should `require_relative './lib'` to allow for individual execution (or else if will only be executable from the runner)
* A test case file should contain a single class which inherits from `IntegrationTest`. It *can* contain multiple classes, but that's bad practice as it makes individual execution harder and implies a dependency between the classes.
* There should be no dependency between the test scripts. Each should be executable individually and the order in which multiple ones are executed mustn't matter.
* The class should contain methods, also prefixed with `test_` which will be executed by the framework. In most cases there would be a single test method per class.
* In case there are multiple test methods, they will be executed in the order in which they are defined.
* The test methods should contain assertions which check for the expected state of things at various points of the test's execution.

### More

* [A basic tutorial on writing integration tests.](tutorial.md)
* [A brief reference of the integration test framework](reference.md)
* Make sure you're familiar with the [idiosyncrasies](idiosyncrasies.md) of writing integration tests
* [Some tips and tricks](tips.md)
