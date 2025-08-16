class AddUniqueIndexToLikes < ActiveRecord::Migration[7.2]
  def change
    add_index :likes,
              [ :user_id, :likeable_type, :likeable_id ],
              unique: true,
              name: "index_likes_on_user_likeable"
  end
end
