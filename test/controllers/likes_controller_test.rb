require "test_helper"

class LikesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @post = posts(:one)
    @user = users(:one)
    @comment = comments(:reply_to_one)
  end

  test "should require login for create" do
    post post_likes_path(@post)

    assert_redirected_to login_path
  end

  test "should create like for current user" do
    log_in_as(@user)

    assert_difference("Like.count", 1) do
      post post_likes_path(@post)
    end

    assert_redirected_to post_path(@post)
    assert_equal @user, @post.reload.likes.order(:created_at).last.user
  end

  test "should destroy like for current user" do
    log_in_as(@user)
    like = @post.likes.create!(user: @user)

    assert_difference("Like.count", -1) do
      delete post_like_path(@post, like)
    end

    assert_redirected_to post_path(@post)
    assert_raises(ActiveRecord::RecordNotFound) { like.reload }
  end

  test "requires login for destroy" do
    like = @post.likes.create!(user: @user)

    delete post_like_path(@post, like)

    assert_redirected_to login_path
  end

  test "requires login for comment like" do
    post comment_likes_path(@comment)

    assert_redirected_to login_path
  end

  test "creates like for comment" do
    log_in_as(@user)

    assert_difference("Like.count", 1) do
      post comment_likes_path(@comment)
    end

    assert_redirected_to post_path(@comment.post)
    assert_equal @user, @comment.reload.likes.order(:created_at).last.user
  end

  test "removes like from comment" do
    log_in_as(@user)
    like = @comment.likes.create!(user: @user)

    assert_difference("Like.count", -1) do
      delete comment_like_path(@comment, like)
    end

    assert_redirected_to post_path(@comment.post)
    assert_raises(ActiveRecord::RecordNotFound) { like.reload }
  end
end
