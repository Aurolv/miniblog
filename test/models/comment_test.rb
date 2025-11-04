require "test_helper"

class CommentTest < ActiveSupport::TestCase
  test "fixture comment is valid" do
    assert comments(:one).valid?
  end

  test "requires body" do
    comment = Comment.new(
      body: "",
      user: users(:one),
      post: posts(:one)
    )

    assert comment.invalid?
    assert_includes comment.errors[:body], "can't be blank"
  end

  test "destroys likes when removed" do
    comment = posts(:one).comments.create!(
      user: users(:two),
      body: "Another comment"
    )
    like = Like.create!(user: users(:one), likeable: comment)

    assert_difference("Like.count", -1) { comment.destroy }
    assert_raises(ActiveRecord::RecordNotFound) { like.reload }
  end

  test "supports threaded replies" do
    parent = comments(:one)
    reply = parent.replies.create!(
      user: users(:two),
      post: parent.post,
      body: "Thanks!"
    )

    assert_equal parent, reply.parent
    assert_includes parent.reload.replies, reply
  end

  test "destroying a comment removes its replies" do
    parent = posts(:one).comments.create!(user: users(:one), body: "Parent comment")
    parent.replies.create!(user: users(:two), post: parent.post, body: "Child reply")

    assert_difference("Comment.count", -2) do
      parent.destroy
    end
  end
end
