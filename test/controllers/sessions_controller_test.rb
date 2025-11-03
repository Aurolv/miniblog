require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get sessions_new_url
    assert_response :success
  end

  test "should create session with valid credentials" do
    user = users(:one)

    post login_path, params: { email: user.email, password: "password" }

    assert_redirected_to root_path
    assert_equal user.id, session[:user_id]
  end

  test "should re-render form with invalid credentials" do
    post login_path, params: { email: "missing@example.com", password: "wrong" }

    assert_response :unprocessable_entity
    assert_nil session[:user_id]
  end

  test "should destroy session" do
    user = users(:one)
    post login_path, params: { email: user.email, password: "password" }

    delete logout_path

    assert_redirected_to root_path
    assert_nil session[:user_id]
  end
end
