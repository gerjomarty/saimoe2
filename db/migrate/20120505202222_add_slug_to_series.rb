class AddSlugToSeries < ActiveRecord::Migration
  def change
    change_table :series do |t|
      t.string :slug, null: false
    end
    add_index :series, :slug, unique: true
  end
end
