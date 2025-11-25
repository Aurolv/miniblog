class CollapseReaderRole < ActiveRecord::Migration[7.2]
  def up
    execute <<~SQL.squish
      UPDATE users
      SET role = CASE
        WHEN role >= 2 THEN 1
        ELSE 0
      END
    SQL
  end

  def down
    execute <<~SQL.squish
      UPDATE users
      SET role = CASE
        WHEN role = 1 THEN 2
        ELSE 0
      END
    SQL
  end
end
