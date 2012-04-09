class CreateMatches < ActiveRecord::Migration
  def change
    create_table :matches do |t|
      t.string  :group,        limit: 1
      t.string  :stage,                        null: false
      t.integer :match_number, limit: 2.bytes
      t.date    :date,                         null: false

      t.timestamps
    end
  end
end
