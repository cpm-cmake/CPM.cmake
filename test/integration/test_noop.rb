# this test does nothing
# it's, in a way, a test of the integration testing framework
require './lib'

class Noop < IntegrationTest
  def test_tt
    make_project
  end
end
