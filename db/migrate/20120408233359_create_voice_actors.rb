class CreateVoiceActors < ActiveRecord::Migration
  def change
    create_table :voice_actors do |t|
      t.string :first_name
      t.string :last_name

      t.timestamps
    end
  end
end
