class CreateTournaments < ActiveRecord::Migration
  def change
    create_table :tournaments do |t|
      t.string :year, null: false, limit: 4

      t.timestamps
    end
  end
end
