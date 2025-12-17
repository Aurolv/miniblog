require "application_system_test_case"

class CommentsTest < ApplicationSystemTestCase
  setup do
    @user = users(:one)
    @post = posts(:one)
  end

  test "user interacts with comments on a post" do
    sign_in_as(@user)

    visit post_path(@post)

    within first(".comment-composer") do
      fill_in "What stood out to you?", with: "Lovely insights!"
      click_on "Post comment"
    end

    assert_text "Lovely insights!"

    comment = find(".comment-bubble", text: "Lovely insights!")

    within comment do
      find(".comment-like-button").click
      assert_selector ".comment-like-button--active"

      reply_section = find("details.comment-reply")
      reply_section.find("summary", text: "Reply").click
      within reply_section.find(".comment-composer--reply") do
        fill_in "Write a thoughtful reply…", with: "Thanks for sharing!"
        click_on "Reply"
      end
    end

    assert_text "Thanks for sharing!"

    within comment do
      accept_confirm do
        click_on "Remove"
      end
    end

    assert_no_text "Lovely insights!"
    assert_no_text "Thanks for sharing!"
  end
end
