require "test_helper"

class AuthControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get auth_url
    assert_response 302
  end
end
