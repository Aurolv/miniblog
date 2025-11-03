require "test_helper"

class LikeTest < ActiveSupport::TestCase
  test "fixture like is valid" do
    assert likes(:one).valid?
  end

  test "prevents duplicate likes per user and likeable" do
    like = Like.new(
      user: likes(:one).user,
      likeable: likes(:one).likeable
    )

    assert like.invalid?
    assert_includes like.errors[:user_id], "has already been taken"
  end

  test "allows the same user to like different likeables" do
    post = posts(:draft)
    like = Like.new(
      user: likes(:one).user,
      likeable: post
    )

    assert like.valid?
  end
end
