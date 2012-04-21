class AddStagesToTournaments < ActiveRecord::Migration
  def change
    change_table :tournaments do |t|
      t.text :group_stages, null: false
      t.text :final_stages, null: false
    end
  end
end
