class RemoveLimitFromGroups < ActiveRecord::Migration
  def up
    change_column :matches, :group, :string, limit: nil
  end

  def down
    change_column :matches, :group, :string, limit: 1
  end
end
