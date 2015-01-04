require File.expand_path('../../lib/game_thrive', __FILE__)
require "minitest/autorun"
require "minitest/pride"
require "fakeweb"

# Overload GameThrive::Client#authorization_header to fix weird testing bug.
# Faraday for some reason prepends "%B5%EB-@" to a domain when an Authorization
# header is present, which breaks FakeWeb stubbing of network requests in tests.
class GameThrive::Client
  protected

  def authorization_header
    {}
  end
end

class GameThrive::UnitTest < MiniTest::Unit::TestCase

  def setup
    GameThrive.configuration.rest_api_key = "test"

    logger = ::Logger.new(STDOUT)
    logger.level = ::Logger::FATAL
    GameThrive.configuration.logger = logger

    FakeWeb.allow_net_connect = false
  end

  def teardown
    FakeWeb.clean_registry
    FakeWeb.allow_net_connect = true
  end

end
