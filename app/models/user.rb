class User < ApplicationRecord
  has_secure_password
  before_validation :normalize_email
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :name, presence: true, uniqueness: true, length: { minimum: 3, maximum: 20 }
  validates :password, length: { minimum: 6 }, if: -> { password.present? }

  has_many :posts, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :likes, dependent: :destroy

  enum :role, { reader: "reader", author: "author", admin: "admin" }, default: :reader

  private

  def normalize_email
    self.email = email.to_s.strip.downcase
  end
end
