require "test_helper"

class FollowTest < ActiveSupport::TestCase
  test "fixture is valid" do
    assert follows(:one).valid?
  end

  test "cannot follow same user twice" do
    follow = Follow.new(follower: users(:one), followed: users(:two))

    assert_not follow.valid?
    assert_includes follow.errors[:followed_id], "has already been taken"
  end

  test "cannot follow yourself" do
    follow = Follow.new(follower: users(:one), followed: users(:one))

    assert_not follow.valid?
    assert_includes follow.errors[:followed_id], "can't be the same as follower"
  end
end
