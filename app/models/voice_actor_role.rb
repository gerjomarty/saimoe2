class VoiceActorRole < ActiveRecord::Base
  attr_accessible :has_no_voice_actor, :appearance, :voice_actor

  belongs_to :appearance, inverse_of: :voice_actor_roles
  belongs_to :voice_actor, inverse_of: :voice_actor_roles

  validates :appearance_id, presence: true
  validates :voice_actor_id, presence: true, unless: :has_no_voice_actor?
end
