require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = users(:one)
    @user = users(:two)
  end

  test "should get index" do
    get users_url
    assert_response :success
  end

  test "should get new" do
    get new_user_url
    assert_response :success
  end

  test "should create user" do
    params = {
      email: "new@example.com",
      password: "password",
      password_confirmation: "password",
      name: "New User",
      bio: "New user bio"
    }

    assert_difference("User.count", 1) do
      post users_url, params: { user: params }
    end

    assert_redirected_to user_url(User.last)
  end

  test "should not create invalid user" do
    assert_no_difference("User.count") do
      post users_url, params: { user: { email: "", password: "short", name: "" } }
    end

    assert_response :unprocessable_entity
  end

  test "should show user" do
    get user_url(@user)
    assert_response :success
  end

  test "should get edit" do
    log_in_as(@user)
    get edit_user_url(@user)
    assert_response :success
  end

  test "should redirect edit when not logged in" do
    get edit_user_url(@user)
    assert_redirected_to login_url
  end

  test "should forbid editing other profile when not admin" do
    log_in_as(@user)
    get edit_user_url(@admin)
    assert_redirected_to user_url(@admin)
    follow_redirect!
    assert_match "cannot modify", response.body
  end

  test "should update user" do
    log_in_as(@user)
    original_digest = @user.password_digest

    patch user_url(@user), params: { user: { name: "Updated Name", password: "", password_confirmation: "" } }
    assert_redirected_to user_url(@user)
    @user.reload
    assert_equal "Updated Name", @user.name
    assert_equal original_digest, @user.password_digest
  end

  test "admin cannot update another user's profile" do
    log_in_as(@admin)
    patch user_url(@user), params: { user: { name: "Hacker" } }
    assert_redirected_to user_url(@user)
    follow_redirect!
    assert_match "cannot modify", response.body
    @user.reload
    assert_not_equal "Hacker", @user.name
  end

  test "should not allow non admin to destroy another user" do
    log_in_as(@user)
    assert_no_difference("User.count") do
      delete user_url(@admin)
    end

    assert_redirected_to user_url(@admin)
  end

  test "admin should destroy user" do
    log_in_as(@admin)
    assert_difference("User.count", -1) do
      delete user_url(@user)
    end

    assert_redirected_to users_url
  end

  test "should search users" do
    get users_url, params: { q: "demo" }

    assert_response :success
    assert_includes @request.query_string, "q=demo"
  end
end
