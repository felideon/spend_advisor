require 'test_helper'
require 'gzo'

include Gzo

class GzoTest < ActiveSupport::TestCase
  def test_ping_returns_pong
    response = ping
    assert(response.code == 200, "HTTP Status: #{response.code}")
    assert(JSON.parse(response.body)["response"] == "PONG")
  end
end
