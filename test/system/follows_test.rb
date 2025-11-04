require "application_system_test_case"

class FollowsTest < ApplicationSystemTestCase
  setup do
    @follower = users(:one)
    @followed = users(:two)
  end

  test "user follows and unfollows another user" do
    visit login_path
    fill_in "Email address", with: @follower.email
    fill_in "Password", with: "password"
    click_on "Log in"

    visit user_path(@followed)

    assert_button "Follow"
    click_on "Follow"

    assert_text "You are now following"
    assert_button "Unfollow"

    click_on "Unfollow"
    assert_text "You unfollowed"
    assert_button "Follow"
  end
end
