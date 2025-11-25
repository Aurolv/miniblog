class ConvertUserRoleToInteger < ActiveRecord::Migration[7.2]
  def up
    add_column :users, :role_tmp, :integer, default: 0, null: false

    execute <<~SQL.squish
      UPDATE users
      SET role_tmp = CASE role
        WHEN 'admin' THEN 2
        WHEN 'author' THEN 1
        ELSE 0
      END
    SQL

    remove_column :users, :role
    rename_column :users, :role_tmp, :role
  end

  def down
    add_column :users, :role_tmp, :string, default: "author", null: false

    execute <<~SQL.squish
      UPDATE users
      SET role_tmp = CASE role
        WHEN 2 THEN 'admin'
        WHEN 1 THEN 'author'
        ELSE 'author'
      END
    SQL

    remove_column :users, :role
    rename_column :users, :role_tmp, :role
  end
end
