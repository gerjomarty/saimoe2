class AddReferencesAndForeignKeys < ActiveRecord::Migration
  def change
    change_table :appearances do |t|
      t.references :character_role, null: false
      t.references :tournament,     null: false
    end
    add_foreign_key :appearances, :character_role_id
    add_foreign_key :appearances, :tournament_id
    add_index :appearances, :character_role_id
    add_index :appearances, :tournament_id

    change_table :characters do |t|
      t.references :main_series,    null: false
    end
    add_foreign_key :characters, :main_series_id, reference_table: :series
    add_index :characters, :main_series_id

    change_table :character_roles do |t|
      t.references :character,      null: false
      t.references :series,         null: false
    end
    add_foreign_key :character_roles, :character_id
    add_foreign_key :character_roles, :series_id
    add_index :character_roles, :character_id
    add_index :character_roles, :series_id

    change_table :matches do |t|
      t.references :tournament,     null: false
    end
    add_foreign_key :matches, :tournament_id
    add_index :matches, :tournament_id

    change_table :match_entries do |t|
      t.references :match,          null: false
      t.references :previous_match
      t.references :appearance
    end
    add_foreign_key :match_entries, :match_id
    add_foreign_key :match_entries, :previous_match_id, reference_table: :matches
    add_foreign_key :match_entries, :appearance_id
    add_index :match_entries, :match_id
    add_index :match_entries, :previous_match_id
    add_index :match_entries, :appearance_id

    change_table :voice_actor_roles do |t|
      t.references :voice_actor
      t.references :appearance,     null: false
    end
    add_foreign_key :voice_actor_roles, :voice_actor_id
    add_foreign_key :voice_actor_roles, :appearance_id
    add_index :voice_actor_roles, :voice_actor_id
    add_index :voice_actor_roles, :appearance_id
  end
end
