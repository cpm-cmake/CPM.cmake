# Tips and Tricks

## Playing and experimenting

Create a file called `test_local.rb` in this directory to have an integration test which is for your personal experiments and just playing with the integration test framework. `test_local.rb` is gitignored.

## Speeding-up development

Running an integration test requires configuring directories with CMake which can be quite slow. To speed-up development of integration tests consider doing the following steps:

**Work with standalone tests**

Instead of starting the runner, run just your integration test (`$ ruby test_your_test.rb`). This won't burden the execution with the others.

**Export the environment variable `CPM_INTEGRATION_TEST_DIR` to some local directory**

By default the framework generates a new temporary directory for each test run. If you override the temp directory to a specific one, rerunning the tests will work with the binary directories from the previous run and will improve the performance considerably.

*NOTE HOWEVER* that in certain cases this may not be an option. Some tests might assert that certain artifacts in the temporary directory are missing but upon rerunning in an existing directory they will be there causing the test to fail.

*ALSO NOTE* that this may silently affect reruns based on CMake caches from previous runs. If your test fails in peculiar ways on reruns, try a clean run. Always do a clean run before declaring a test a success.

**Set `CPM_SOURCE_CACHE` even if the test doesn't require it**

This is not a option for tests which explicitly check that there is no source cache. However certain tests may be indiferent to this. For such cases in development, you can add a setup function in the lines of:

```ruby
def setup
  ENV['CPM_SOURCE_CACHE'] = '/home/myself/.testcpmcache'
end
```

Then the packages from your test will be cached and not redownloaded every time which is a dramatic improvement in performance.

*NOTE HOWEVER* that this may introduce subtle bugs. Always test without this dev-only addition, before declaring a test a success.
