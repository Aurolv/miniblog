class Follow < ApplicationRecord
  belongs_to :follower, class_name: "User"
  belongs_to :followed, class_name: "User"

  validates :followed_id, uniqueness: { scope: :follower_id }
  validate :prevent_self_follow

  private

  def prevent_self_follow
    return unless follower_id.present? && follower_id == followed_id

    errors.add(:followed_id, "can't be the same as follower")
  end
end
