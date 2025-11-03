require "test_helper"

class LikesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @post = posts(:one)
    @user = users(:one)
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
end
