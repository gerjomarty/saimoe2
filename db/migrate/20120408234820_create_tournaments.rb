class CreateTournaments < ActiveRecord::Migration
  def change
    create_table :tournaments do |t|
      t.string :year, limit: 4, null: false

      t.timestamps
    end
  end
end
