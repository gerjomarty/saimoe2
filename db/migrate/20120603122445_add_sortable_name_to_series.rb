class AddSortableNameToSeries < ActiveRecord::Migration
  def change
    add_column :series, :sortable_name, :string, null: false
  end
end
