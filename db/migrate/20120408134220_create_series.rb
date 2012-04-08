class CreateSeries < ActiveRecord::Migration
  def change
    create_table :series do |t|
      t.string :name,       null: false
      t.string :color_code, limit: 6

      t.timestamps
    end
  end
end
