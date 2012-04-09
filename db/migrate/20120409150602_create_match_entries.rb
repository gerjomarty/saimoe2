class CreateMatchEntries < ActiveRecord::Migration
  def change
    create_table :match_entries do |t|
      t.integer :position,        null: false
      t.integer :number_of_votes

      t.timestamps
    end
  end
end
