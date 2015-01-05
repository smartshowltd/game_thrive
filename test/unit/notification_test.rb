require File.expand_path('../../test_helper', __FILE__)

class NotificationTest < GameThrive::UnitTest

  def setup
    super

    FakeWeb.register_uri :get, "https://gamethrive.com/api/v1/notifications/458dcec4-cf53-11e3-add2-000c2940e62c?app_id=app-id", :body => JSON.dump(sample_notification_attributes), :status => 200
  end

  def test_create
    response_body = {"id" => "458dcec4-cf53-11e3-add2-000c2940e62c", "recipients" => 1}
    FakeWeb.register_uri :post, "https://gamethrive.com/api/v1/notifications", :body => JSON.dump(response_body), :status => 200
    response = GameThrive::Notification.create(:app_id => "app-id", :is_ios => true, :contents => { :en => "Test message" }, :include_ios_tokens => ["ce777617da7f548fe7a9ab6febb56cf39fba6d382000c0395666288d961ee566"])
    assert_equal response_body, response
    assert JSON.parse(FakeWeb.last_request.body).include?("isIos")
  end

  def test_find
    notification = GameThrive::Notification.find("458dcec4-cf53-11e3-add2-000c2940e62c", :app_id => "app-id")
    sample_notification_attributes.each do |key, value|
      assert_equal value, notification.send(key.to_sym)
    end
    assert notification.persisted?
    assert !notification.dirty?

    FakeWeb.register_uri :get, "https://gamethrive.com/api/v1/notifications/458dcec4-cf53-11e3-add2-000000000000?app_id=app-id", :body => "Bad Request", :status => 400

    assert_raises GameThrive::Client::BadRequestError do
      GameThrive::Notification.find("458dcec4-cf53-11e3-add2-000000000000", :app_id => "app-id")
    end
  end

  def test_list
    list_body = sample_list_attributes.merge("notifications" => [sample_notification_attributes])
    FakeWeb.register_uri :get, "https://gamethrive.com/api/v1/notifications?app_id=app-id&limit=50&offset=0", :body => JSON.dump(list_body), :status => 200
    notifications = GameThrive::Notification.list(:app_id => "app-id")
    assert_equal 1, notifications.count
    sample_notification_attributes.each do |key, value|
      assert_equal value, notifications.first.send(key.to_sym)
    end
  end

  def test_count
    list_body = sample_list_attributes.merge("notifications" => [sample_notification_attributes])
    FakeWeb.register_uri :get, "https://gamethrive.com/api/v1/notifications?app_id=app-id&limit=1&offset=0", :body => JSON.dump(list_body), :status => 200
    assert_equal 1, GameThrive::Notification.count(:app_id => "app-id")
  end

  def test_delete
    response_body = { "success" => true }
    FakeWeb.register_uri :delete, "https://gamethrive.com/api/v1/notifications/458dcec4-cf53-11e3-add2-000c2940e62c?app_id=app-id", :body => JSON.dump(response_body), :status => 200
    notification = GameThrive::Notification.find("458dcec4-cf53-11e3-add2-000c2940e62c", :app_id => "app-id")
    notification.delete!(:app_id => "app-id")
    assert_equal "/api/v1/notifications/458dcec4-cf53-11e3-add2-000c2940e62c?app_id=app-id", FakeWeb.last_request.path
    assert_equal "DELETE", FakeWeb.last_request.method
  end

  protected

    def sample_list_attributes
      {
        "total_count" => 1,
        "offset"      => 0,
        "limit"       => 50
      }
    end

    def sample_notification_attributes
      {
        "id"          => "458dcec4-cf53-11e3-add2-000c2940e62c",
        "successful"  => 15,
        "failed"      => 1,
        "converted"   => 3,
        "remaining"   => 0,
        "queued_at"   => 1415914655,
        "contents"    => {
          "en" => "abc",
          "es" => "def"
        }
      }
    end

end
