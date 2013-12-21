class AddImageToSeries < ActiveRecord::Migration
  def change
    add_column :series, :image, :string
  end
end
