class AddSlugToCharacters < ActiveRecord::Migration
  def change
    change_table :characters do |t|
      t.string :slug, null: false
    end
    add_index :characters, :slug, unique: true
  end
end
