class AddPlayoffGroupStagesToTournament < ActiveRecord::Migration
  def change
    change_table :tournaments do |t|
      t.text :group_stages_with_playoffs_to_display, null: true
    end
  end
end
