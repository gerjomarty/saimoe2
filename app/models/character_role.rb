class CharacterRole < ActiveRecord::Base
  attr_accessible :role_type

  belongs_to :character, inverse_of: :character_roles
  belongs_to :series, inverse_of: :character_roles
  has_many :appearances, inverse_of: :character_role

  validates :role_type, presence: true
  validates :character_id, :series_id, presence: true, numericality: {only_integer: true}
end
