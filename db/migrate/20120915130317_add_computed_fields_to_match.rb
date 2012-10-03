class AddComputedFieldsToMatch < ActiveRecord::Migration
  def change
    change_table :matches do |t|
      t.boolean :is_finished, null: true, default: nil
      t.integer :number_of_votes, null: true, default: nil
      t.boolean :is_draw, null: true, default: nil
      t.float :table_height, null: true, default: nil
    end
  end
end
