class AddAvatarsToCharactersAndAppearances < ActiveRecord::Migration
  def change
    add_column :characters, :avatar, :string
    add_column :appearances, :character_avatar, :string
  end
end
