require "test_helper"

class PostsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @post = posts(:one)
    @draft_post = posts(:draft)
    log_in_as(@user)
  end

  test "should get index" do
    get posts_url
    assert_response :success
  end

  test "should get new" do
    get new_post_url
    assert_response :success
  end

  test "should create post" do
    travel_to Time.current do
      attrs = {
        title: "New Unique Title",
        body: "This body is long enough to pass validation.",
        status: "published"
      }

      assert_difference("Post.count", 1) do
        post posts_url, params: { post: attrs }
      end

      created = Post.order(:id).last
      assert_redirected_to post_url(created)
      assert_equal @user.id, created.user_id
      assert created.published?
      assert_not_nil created.published_at
    end
  end

  test "should not create invalid post" do
    attrs = { title: "", body: "Too short", status: "draft" }

    assert_no_difference("Post.count") do
      post posts_url, params: { post: attrs }
    end

    assert_response :unprocessable_entity
  end

  test "should show post" do
    get post_url(@post)
    assert_response :success
    assert_match "Discussion", response.body
    assert_match comments(:one).body, response.body
  end

  test "should get edit" do
    get edit_post_url(@post)
    assert_response :success
  end

  test "should update post" do
    patch post_url(@post), params: { post: { title: "Updated Title", body: @post.body, status: @post.status } }
    assert_redirected_to post_url(@post)
    assert_equal "Updated Title", @post.reload.title
  end

  test "should destroy post" do
    assert_difference("Post.count", -1) do
      delete post_url(@post)
    end

    assert_redirected_to posts_url
  end

  test "requires login for drafts" do
    delete logout_path

    get drafts_posts_url

    assert_redirected_to login_path
  end

  test "should return drafts for current user" do
    get drafts_posts_url

    assert_response :success
    assert_match @draft_post.title, response.body
  end

  test "owner viewing draft sees no reactions" do
    get post_url(@draft_post)

    assert_response :success
    refute_includes response.body, "Discussion"
    refute_includes response.body, "Post comment"
    assert_includes response.body, "This draft is private"
  end

  test "should publish draft post" do
    assert_changes -> { @draft_post.reload.status }, from: "draft", to: "published" do
      patch publish_post_url(@draft_post)
    end

    assert @draft_post.reload.published?
    assert_not_nil @draft_post.published_at
    assert_redirected_to post_url(@draft_post)
  end

  test "should forbid publishing post not owned by user" do
    log_in_as(users(:two))

    patch publish_post_url(@post)

    assert_response :forbidden
  end

  test "non owner cannot view draft" do
    delete logout_path
    log_in_as(users(:two))

    get post_url(@draft_post)

    assert_redirected_to posts_url
  end

  test "should search published posts" do
    get search_posts_url, params: { q: "Published" }

    assert_response :success
    assert_match @post.title, response.body
  end
end
