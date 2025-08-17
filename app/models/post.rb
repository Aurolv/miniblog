class Post < ApplicationRecord
  belongs_to :user
  has_many :likes, as: :likeable, dependent: :destroy

  enum status: { draft: "draft", published: "published" }

  validates :title, :body, presence: true

  scope :published, -> { where(status: :published) }
  scope :search, ->(q) { q.present? ? where("title ILIKE :q OR body ILIKE :q", q: "%#{q}%") : all }
end
