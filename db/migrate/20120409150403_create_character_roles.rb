class CreateCharacterRoles < ActiveRecord::Migration
  def change
    create_table :character_roles do |t|
      t.string :role_type, null: false

      t.timestamps
    end
  end
end
