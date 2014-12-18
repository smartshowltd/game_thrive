require File.expand_path('../../test_helper', __FILE__)

class PlayerTest < Gamethrive::UnitTest

  def setup
    super

    # Sample valid player
    FakeWeb.register_uri :get, "https://gamethrive.com/api/v1/players/ffffb794-ba37-11e3-8077-031d62f86ebf", :body => JSON.dump(player_attributes)
  end

  def test_create
    response_body = { "success" => true, "id" => "ffffb794-ba37-11e3-8077-031d62f86ebf" }
    FakeWeb.register_uri :post, "https://gamethrive.com/api/v1/players", :body => JSON.dump(response_body)

    # Success
    response = Gamethrive::Player.create :app_id => "app-id", :device_type => 0, :identifier => "012345"
    assert_equal response_body, response

    FakeWeb.register_uri :post, "https://gamethrive.com/api/v1/players", :body => "Bad request", :status => 400

    # Fail, emulating missing params.
    assert_raises Gamethrive::Client::BadRequestError do
      Gamethrive::Player.create :app_id => "app-id"
    end
  end

  def test_find
    FakeWeb.register_uri :get, "https://gamethrive.com/api/v1/players/ffffb794-ba37-11e3-8077-000000000000", :body => "Not Found", :status => 400

    player = Gamethrive::Player.find("ffffb794-ba37-11e3-8077-031d62f86ebf")
    assert_kind_of Gamethrive::Player, player
    player_attributes.except("invalid_identifier").each do |key, value|
      assert_equal value, player.send(key.to_sym)
    end
    assert !player.dirty?
    assert player.persisted?

    assert_raises Gamethrive::Client::BadRequestError do
      Gamethrive::Player.find("ffffb794-ba37-11e3-8077-000000000000")
    end
  end

  def test_update_attributes
    FakeWeb.register_uri :put, "https://gamethrive.com/api/v1/players/ffffb794-ba37-11e3-8077-031d62f86ebf", :body => JSON.dump("success" => true), :status => 200
    player = Gamethrive::Player.find("ffffb794-ba37-11e3-8077-031d62f86ebf")
    response = player.update_attributes(:game_version => "2.0")
    assert_equal({ "success" => true }, response)
    assert_equal "2.0", player.game_version
  end

  def test_save
    FakeWeb.register_uri :put, "https://gamethrive.com/api/v1/players/ffffb794-ba37-11e3-8077-031d62f86ebf", :body => JSON.dump("success" => true), :status => 200
    FakeWeb.register_uri :post, "https://gamethrive.com/api/v1/players", :body => JSON.dump("success" => true), :status => 200

    player = Gamethrive::Player.find("ffffb794-ba37-11e3-8077-031d62f86ebf")
    player.game_version = "3.0"
    response = player.save
    assert_equal({ "success" => true }, response)
    assert_equal "/api/v1/players/ffffb794-ba37-11e3-8077-031d62f86ebf", FakeWeb.last_request.path

    player = Gamethrive::Player.new(:app_id => "app-id", :device_type => 0, :identifier => "012345")
    response = player.save
    assert_equal({ "success" => true }, response)
    assert_equal "/api/v1/players", FakeWeb.last_request.path
  end

  def test_persisted?
    player = Gamethrive::Player.find("ffffb794-ba37-11e3-8077-031d62f86ebf")
    assert player.persisted?

    player2 = Gamethrive::Player.new
    assert !player2.persisted?
  end

  def test_reload
    player = Gamethrive::Player.find("ffffb794-ba37-11e3-8077-031d62f86ebf")
    player.game_version = "4.0"
    assert_equal "4.0", player.game_version
    assert player.dirty?
    player.reload!
    assert_equal "/api/v1/players/ffffb794-ba37-11e3-8077-031d62f86ebf", FakeWeb.last_request.path
    assert_equal player_attributes["game_version"], player.game_version
    assert !player.dirty?
  end

  def test_list
    response_body = list_attributes.merge("players" => [player_attributes])
    FakeWeb.register_uri :get, "https://gamethrive.com/api/v1/players?app_id=app-id&limit=50&offset=0", :body => JSON.dump(response_body), :status => 200
    players = Gamethrive::Player.list(:app_id => "app-id")
    assert_equal 1, players.count
    player_attributes.except("invalid_identifier").each do |key, value|
      assert_equal value, players.first.send(key.to_sym)
    end
  end

  def test_count
    response_body = list_attributes.merge("players" => player_attributes)
    FakeWeb.register_uri :get, "https://gamethrive.com/api/v1/players?app_id=app-id&limit=1&offset=0", :body => JSON.dump(response_body), :status => 200
    assert_equal 1, Gamethrive::Player.count(:app_id => "app-id")
  end

  protected

    def list_attributes
      {
        "total_count" => 1,
        "offset"      => 0,
        "limit"       => 50
      }
    end

    def player_attributes
      {
        "id"                  => "ffffb794-ba37-11e3-8077-031d62f86ebf",
        "identifier"          => "ce777617da7f548fe7a9ab6febb56cf39fba6d382000c0395666288d961ee566",
        "session_count"       => 1,
        "language"            => "en",
        "timezone"            => -28800,
        "game_version"        => "1.0",
        "device_os"           => "7.0.4",
        "device_type"         => 0,
        "device_model"        => "iPhone",
        "ad_id"               => nil,
        "tags"                => { "a" => "1","foo" => "bar" },
        "last_active"         => 1395096859,
        "amount_spent"        => "0",
        "created_at"          => 1395096859,
        "invalid_identifier"  => false,
        "badge_count"         => 0
      }
    end

end
