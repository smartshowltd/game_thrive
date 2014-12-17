require File.expand_path('../../test_helper', __FILE__)

class ClientTest < Gamethrive::UnitTest

  def test_request
    body = JSON.dump(:message => "Hello World!")
    FakeWeb.register_uri(:get, "https://gamethrive.com/api/v1/test", :body => body)

    response = Gamethrive::Client.get "/test"

    assert_kind_of Gamethrive::Client, response.request
    assert_equal 200, response.status
    assert_equal body, response.raw_body
    assert_equal({ "message" => "Hello World!"}, response.body)
  end

end
