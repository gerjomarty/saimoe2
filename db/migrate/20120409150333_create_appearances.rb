class CreateAppearances < ActiveRecord::Migration
  def change
    create_table :appearances do |t|
      t.string :character_display_name

      t.timestamps
    end
  end
end
