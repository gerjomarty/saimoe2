class AddComputedFieldsToMatchEntry < ActiveRecord::Migration
  def change
    change_table :match_entries do |t|
      t.boolean :is_finished, null: true, default: nil
      t.boolean :is_winner, null: true, default: nil
      t.float :vote_share, null: true, default: nil
      t.float :table_height, null: true, default: nil
      t.string :character_name, null: true, default: nil
    end
  end
end
