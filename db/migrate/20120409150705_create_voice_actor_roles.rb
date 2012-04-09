class CreateVoiceActorRoles < ActiveRecord::Migration
  def change
    create_table :voice_actor_roles do |t|
      t.boolean :has_no_voice_actor, default: false

      t.timestamps
    end
  end
end
