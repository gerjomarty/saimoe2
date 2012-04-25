class CharacterRole < ActiveRecord::Base
  attr_accessible :role_type, :character, :series

  belongs_to :character, inverse_of: :character_roles
  belongs_to :series, inverse_of: :character_roles
  has_many :appearances, inverse_of: :character_role

  ROLE_TYPES = [:major, :cameo].freeze

  validates :role_type, presence: true, inclusion: {in: ROLE_TYPES}
  validates :character_id, :series_id, presence: true

  def role_type
    (value = read_attribute(:role_type)) && value.to_sym
  end

  def role_type= value
    write_attribute(:role_type, value && value.to_s)
  end
end
