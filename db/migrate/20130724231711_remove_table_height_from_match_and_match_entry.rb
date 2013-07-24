class RemoveTableHeightFromMatchAndMatchEntry < ActiveRecord::Migration
  def up
    remove_column :match_entries, :table_height
    remove_column :matches, :table_height
  end

  def down
    add_column :matches, :table_height, :float, null: true, default: nil
    add_column :match_entries, :table_height, :float, null: true, default: nil
  end
end
