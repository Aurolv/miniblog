require "securerandom"

ActiveRecord::Base.transaction do
  puts "Cleaning up existing data..."
  [ Like, Comment, Post, Follow, User ].each(&:delete_all)

  PASSWORD = "password"

  bios = [
    "Product designer who writes about creativity and focus.",
    "Rails developer sharing tips and dev diaries.",
    "Storyteller, traveler, and amateur photographer.",
    "Edtech founder writing about learning in public.",
    "Community manager who loves thoughtful discussions."
  ]

  names = %w[Alice Bob Charlie Diana Evan]

  users = names.each_with_index.map do |name, idx|
    User.create!(
      name: name,
      email: "user#{idx + 1}@example.com",
      password: PASSWORD,
      password_confirmation: PASSWORD,
      bio: bios[idx],
      role: idx.zero? ? :admin : :author
    )
  end

  puts "Created #{users.count} users"

  thoughts = [
    "Rails continues to surprise me. Today I learned…",
    "Notes on building delightful interfaces without JS-heavy stacks.",
    "An honest retro on my last side-project launch.",
    "Little things I changed in my workflow to stay focused.",
    "Ideas for making remote collaboration feel human."
  ]

  published_posts = []

  users.each do |user|
    3.times do |i|
      published_posts << user.posts.create!(
        title: "#{user.name}'s published story ##{i + 1}",
        body: thoughts.sample,
        status: :published,
        published_at: rand(5..30).days.ago
      )
    end

    2.times do |i|
      user.posts.create!(
        title: "#{user.name}'s draft note ##{i + 1}",
        body: "Working draft: #{thoughts.sample} This one still needs polish.",
        status: :draft
      )
    end
  end

  puts "Created #{Post.count} posts (#{published_posts.size} published, #{Post.draft.count} drafts)"

  comments = []
  comment_bodies = [
    "Love this perspective!",
    "Have you tried applying this to client work?",
    "This resonates a lot—thanks for sharing.",
    "Curious how you approached the research here.",
    "👏👏👏"
  ]

  published_posts.each do |post|
    commenters = users.reject { |u| u == post.user }.sample(3)
    commenters.each do |commenter|
      comments << post.comments.create!(
        user: commenter,
        body: comment_bodies.sample
      )
    end
  end

  puts "Created #{comments.count} comments"

  published_posts.each do |post|
    users.sample(rand(1..users.size)).each do |liker|
      post.likes.find_or_create_by!(user: liker)
    end
  end

  comments.each do |comment|
    users.sample(rand(0..users.size / 2)).each do |liker|
      comment.likes.find_or_create_by!(user: liker)
    end
  end

  users.each do |user|
    (users - [ user ]).sample(rand(1..users.size - 1)).each do |followed|
      Follow.find_or_create_by!(follower: user, followed: followed)
    end
  end

  puts <<~TEXT
    ---
    Seed summary:
      Users:    #{User.count}
      Posts:    #{Post.count} (#{Post.published.count} published / #{Post.draft.count} drafts)
      Comments: #{Comment.count}
      Likes:    #{Like.count}
      Follows:  #{Follow.count}
    ---
  TEXT
end
