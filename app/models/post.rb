class Post < ApplicationRecord
  belongs_to :user
  has_many :likes, as: :likeable, dependent: :destroy

  enum status: { draft: "draft", published: "published" }

  validates :title, :body, presence: true
end
