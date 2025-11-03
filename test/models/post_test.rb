require "test_helper"

class PostTest < ActiveSupport::TestCase
  test "fixtures are valid" do
    assert posts(:one).valid?
    assert posts(:draft).valid?
  end

  test "requires title presence" do
    post = Post.new(
      body: "This is a valid post body.",
      status: :draft,
      user: users(:one)
    )

    assert post.invalid?
    assert_includes post.errors[:title], "can't be blank"
  end

  test "requires unique title per user ignoring case" do
    duplicate = posts(:one).dup
    duplicate.title = posts(:one).title.upcase
    duplicate.status = :draft
    duplicate.published_at = nil

    assert duplicate.invalid?
    assert_includes duplicate.errors[:title], "has already been taken"
  end

  test "requires body with minimum length" do
    post = Post.new(
      title: "Short Body",
      body: "Too short",
      status: :draft,
      user: users(:one)
    )

    assert post.invalid?
    assert_includes post.errors[:body], "is too short (minimum is 10 characters)"
  end

  test "validates published_at presence for published posts" do
    post = Post.new(
      title: "Published Without Timestamp",
      body: "This body is long enough for validation.",
      status: :published,
      user: users(:one)
    )

    assert post.invalid?
    assert_includes post.errors[:published_at], "must present for published posts"
  end

  test "published scope selects only published posts" do
    assert_equal [ posts(:one) ], Post.published.to_a
  end

  test "search matches by title or body regardless of case" do
    create_post = users(:one).posts.create!(
      title: "Another interesting story",
      body: "Keyword rich content about Rails testing best practices.",
      status: :published,
      published_at: Time.current
    )

    testing_results = Post.published.search("testing")
    published_results = Post.published.search("Published")

    assert_includes testing_results, create_post
    refute_includes testing_results, posts(:one)
    assert_includes published_results, posts(:one)
    refute_includes published_results, posts(:draft)
  end
end
