class VoiceActorRole < ActiveRecord::Base
  attr_accessible :has_no_voice_actor

  belongs_to :appearance, inverse_of: :voice_actor_roles
  belongs_to :voice_actor, inverse_of: :voice_actor_roles

  validates :voice_actor_id, numericality: {only_integer: true}
  validates :appearance_id, presence: true, numericality: {only_integer: true}
end
