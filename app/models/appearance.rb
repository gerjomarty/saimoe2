class Appearance < ActiveRecord::Base
  attr_accessible :character_display_name

  belongs_to :character_role, inverse_of: :appearances
  belongs_to :tournament, inverse_of: :appearances
  has_many :match_entries, inverse_of: :appearance
  has_many :voice_actor_roles, inverse_of: :appearance

  validates :character_role_id, :tournament_id, presence: true, numericality: {only_integer: true}
end
