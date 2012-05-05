class AddSlugToVoiceActors < ActiveRecord::Migration
  def change
    change_table :voice_actors do |t|
      t.string :slug, null: false
    end
    add_index :voice_actors, :slug, unique: true
  end
end
