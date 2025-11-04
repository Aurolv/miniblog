class Comment < ApplicationRecord
  belongs_to :user
  belongs_to :post
  belongs_to :parent, class_name: "Comment", optional: true, inverse_of: :replies
  has_many :likes, as: :likeable, dependent: :destroy
  has_many :replies, class_name: "Comment", foreign_key: :parent_id, dependent: :destroy, inverse_of: :parent

  validates :body, presence: true

  scope :roots, -> { where(parent_id: nil) }
end
