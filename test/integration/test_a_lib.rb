require_relative './lib'

# Tests and experiments with the integration test framework itself

class ALib < IntegrationTest
  def test_zza
    f = -> {
      assert_equal 2, 2
    }
    f.()
  end

  def test_b
    test_foo('xxx')
  end

  def test_foo(xxx)
    assert_equal 'xxx', xxx
  end
end
