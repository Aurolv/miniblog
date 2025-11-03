require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "fixture user is valid" do
    assert users(:one).valid?
  end

  test "normalizes email before validation" do
    user = User.create!(
      email: "NewUser@Example.COM ",
      password: "password",
      password_confirmation: "password",
      name: "NewUser"
    )

    assert_equal "newuser@example.com", user.email
  end

  test "enforces unique email regardless of case" do
    user = User.new(
      email: users(:one).email.upcase,
      password: "password",
      password_confirmation: "password",
      name: "AnotherUser"
    )

    assert user.invalid?
    assert_includes user.errors[:email], "has already been taken"
  end

  test "requires password with minimum length" do
    user = User.new(
      email: "short@example.com",
      password: "12345",
      password_confirmation: "12345",
      name: "Shorty"
    )

    assert user.invalid?
    assert_includes user.errors[:password], "is too short (minimum is 6 characters)"
  end

  test "destroys dependent associations" do
    user = User.create!(
      email: "owner@example.com",
      password: "password",
      password_confirmation: "password",
      name: "Owner"
    )
    post = user.posts.create!(
      title: "Associated Post",
      body: "This body is long enough to be valid.",
      status: :draft
    )
    user.comments.create!(body: "Nice!", post: post)
    user.likes.create!(likeable: post)

    assert_difference([ "Post.count", "Comment.count", "Like.count" ], -1) do
      user.destroy
    end
  end

  test "defaults to reader role" do
    user = User.create!(
      email: "role@example.com",
      password: "password",
      password_confirmation: "password",
      name: "RoleUser"
    )

    assert_equal "reader", user.role
  end
end
