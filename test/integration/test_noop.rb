# this test does nothing
# it's, in a way, a test of the integration testing framework

class Noop < Test::Unit::TestCase
  def test_tt
    puts 'run'
    assert true
    assert_equal 1, 1
  end
end
