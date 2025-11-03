require "test_helper"

class CommentsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @post = posts(:one)
    @user = users(:one)
  end

  test "requires login for create" do
    post post_comments_path(@post), params: { comment: { body: "Test" } }

    assert_redirected_to login_path
  end

  test "creates comment for signed-in user" do
    log_in_as(@user)

    assert_difference("Comment.count", 1) do
      post post_comments_path(@post), params: { comment: { body: "Great post!" } }
    end

    assert_redirected_to post_path(@post)
    comment = Comment.order(:created_at).last
    assert_equal @user, comment.user
    assert_equal @post, comment.post
  end

  test "does not create invalid comment" do
    log_in_as(@user)

    assert_no_difference("Comment.count") do
      post post_comments_path(@post), params: { comment: { body: "" } }
    end

    assert_response :unprocessable_entity
  end

  test "destroys comment owned by user" do
    log_in_as(@user)
    comment = @post.comments.create!(user: @user, body: "Owned comment")

    assert_difference("Comment.count", -1) do
      delete comment_path(comment)
    end

    assert_redirected_to post_path(@post)
    assert_raises(ActiveRecord::RecordNotFound) { comment.reload }
  end

  test "requires login for destroy" do
    comment = @post.comments.create!(user: @user, body: "Login required")

    delete comment_path(comment)

    assert_redirected_to login_path
  end

  test "forbids destroying comment owned by another user" do
    log_in_as(users(:two))
    comment = @post.comments.create!(user: @user, body: "Not yours")

    delete comment_path(comment)

    assert_response :forbidden
  end
end
