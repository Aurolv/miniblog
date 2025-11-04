class Post < ApplicationRecord
  belongs_to :user
  has_many :likes, as: :likeable, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :root_comments, -> { roots }, class_name: "Comment"
  validates :title, presence: true, uniqueness: { scope: :user_id, case_sensitive: false }, length: { minimum: 3, maximum: 150 }
  validates :body, presence: true, length: { minimum: 10 }
  enum :status, { draft: "draft", published: "published" }
  validates :status, inclusion: { in: statuses.keys }
  validate :published_at_presence_for_published

  scope :published, -> { where(status: :published) }
  scope :search, ->(q) { q.present? ? where("title ILIKE :q OR body ILIKE :q", q: "%#{q}%") : all }

  private

  def published_at_presence_for_published
    if published? && published_at.blank?
      errors.add(:published_at, "must present for published posts")
    end
  end
end
