require "application_system_test_case"

class FollowsTest < ApplicationSystemTestCase
  setup do
    @follower = users(:one)
    @followed = users(:two)
    Follow.delete_all
  end

  test "user follows and unfollows another user" do
    sign_in_as(@follower)

    visit user_path(@followed)
    within ".user-follow-actions" do
      click_on "Follow"
    end

    assert_text "You are now following #{@followed.name}."

    within ".user-follow-actions" do
      accept_confirm "Unfollow #{@followed.name}?" do
        click_on "Unfollow"
      end
    end
    assert_text "You unfollowed #{@followed.name}."
    assert_button "Follow"
  end
end
