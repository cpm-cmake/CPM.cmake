# Notable Idiosyncrasies When Writing Integration Tests

As an integration test framework based on a unit test framework the one created for CPM.cmake suffers from several idiosyncrasies. Make sure you familiarize yourself with them before writing integration tests.

## No shared instance variables between methods

The runner will create an instance of the test class for each test method. This means that instance variables defined in a test method, *will not* be visible in another. For example:

```ruby
class MyTest < IntegrationTest
  def test_something
    @x = 123
    assert_equal 123, @x # Pass. @x is 123
  end
  def test_something_else
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
  def test_something_else
    assert_equal 123, @x # Pass. @x is 123 thanks to setup
  end
end
```

## `IntegrationTest` makes use of `Test::Unit::TestCase#cleanup`

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

## It's better to have assertions in test methods as opposed to helper methods

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
