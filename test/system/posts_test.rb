require "application_system_test_case"

class PostsTest < ApplicationSystemTestCase
  setup do
    @post = posts(:one)
    @user = users(:one)
  end

  test "visiting the index" do
    visit posts_url
    assert_selector ".posts-directory-title", text: "Browse inspiring writing"
  end

  test "should create post" do
    sign_in_as(@user)

    visit posts_url
    click_on "New post"

    fill_in "Title", with: "System Test Post"
    fill_in "Body", with: "This body was written by a system test to ensure posting works."
    select "Published", from: "Status"
    click_on "Create post"

    assert_text "Post was successfully created."
  end

  test "should update post" do
    sign_in_as(@post.user)

    visit post_url(@post)
    click_on "Edit", match: :first

    fill_in "Title", with: "Updated Title from System Test"
    fill_in "Body", with: "Updated body content from system test."
    click_on "Save changes"

    assert_text "Post was successfully updated."
  end

  test "should destroy post" do
    post = @user.posts.create!(
      title: "Disposable Post",
      body: "Body created so the system test can delete it safely.",
      status: :published,
      published_at: Time.current
    )

    sign_in_as(@user)

    visit post_url(post)
    accept_confirm { click_on "Delete" }

    assert_text "Post was successfully destroyed."
  end
end
