require "test_helper"

class FollowsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @follower = users(:one)
    @followed = users(:two)
    Follow.delete_all
  end

  test "requires login" do
    post user_follow_path(@followed)
    assert_redirected_to login_path
  end

  test "creates follow" do
    log_in_as(@follower)

    assert_difference("Follow.count", 1) do
      post user_follow_path(@followed)
    end

    assert_redirected_to user_path(@followed)
  end

  test "does not allow duplicate follow" do
    log_in_as(@follower)
    post user_follow_path(@followed)

    assert_no_difference("Follow.count") do
      post user_follow_path(@followed)
    end

    assert_redirected_to user_path(@followed)
  end

  test "destroys follow" do
    log_in_as(@follower)
    post user_follow_path(@followed)
    follow = Follow.last

    assert_difference("Follow.count", -1) do
      delete user_follow_path(@followed)
    end

    assert_redirected_to user_path(@followed)
    assert_raises(ActiveRecord::RecordNotFound) { follow.reload }
  end

  test "cannot follow yourself" do
    log_in_as(@follower)

    assert_no_difference("Follow.count") do
      post user_follow_path(@follower)
    end

    assert_redirected_to user_path(@follower)
  end
end
