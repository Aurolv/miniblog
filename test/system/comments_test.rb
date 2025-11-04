require "application_system_test_case"

class CommentsTest < ApplicationSystemTestCase
  setup do
    @user = users(:one)
    @post = posts(:one)
  end

  test "user interacts with comments on a post" do
    visit login_path
    fill_in "Email address", with: @user.email
    fill_in "Password", with: "password"
    click_on "Log in"

    visit post_path(@post)

    within ".comment-form-card" do
      fill_in "Share your thoughts", with: "Lovely insights!"
      click_on "Post comment"
    end

    assert_text "Lovely insights!"

    within find(".comment-card", text: "Lovely insights!") do
      find(".comment-like-button").click
      assert_selector ".comment-like-button--active"

      click_on "Reply"
      within first(".comment-form") do
        fill_in "Share your reply", with: "Thanks for sharing!"
        click_on "Reply"
      end

      assert_text "Thanks for sharing!"

      accept_confirm do
        click_on "Remove"
      end
    end

    assert_no_text "Lovely insights!"
    assert_no_text "Thanks for sharing!"
  end
end
