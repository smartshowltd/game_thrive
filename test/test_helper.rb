require File.expand_path('../../lib/gamethrive', __FILE__)
require "minitest/autorun"
require "minitest/pride"
require "fakeweb"

class Gamethrive::UnitTest < MiniTest::Unit::TestCase

  def setup
    FakeWeb.allow_net_connect = false
  end

  def teardown
    FakeWeb.clean_registry
    FakeWeb.allow_net_connect = true
  end

end
