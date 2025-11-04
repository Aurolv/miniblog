class User < ApplicationRecord
  has_secure_password
  before_validation :normalize_email
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :name, presence: true, uniqueness: true, length: { minimum: 3, maximum: 20 }
  validates :password, length: { minimum: 6 }, if: -> { password.present? }

  has_many :posts, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :likes, dependent: :destroy
  has_many :following_relationships, class_name: "Follow", foreign_key: :follower_id, dependent: :destroy
  has_many :following, through: :following_relationships, source: :followed
  has_many :follower_relationships, class_name: "Follow", foreign_key: :followed_id, dependent: :destroy
  has_many :followers, through: :follower_relationships, source: :follower

  enum :role, { reader: "reader", author: "author", admin: "admin" }, default: :reader

  def following?(user)
    following.exists?(user.id)
  end

  def follow!(user)
    return if user == self

    following_relationships.find_or_create_by!(followed: user)
  end

  def unfollow!(user)
    relationship = following_relationships.find_by(followed: user)
    relationship&.destroy
  end

  private

  def normalize_email
    self.email = email.to_s.strip.downcase
  end
end
