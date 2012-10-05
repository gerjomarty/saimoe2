class CharacterRole < ActiveRecord::Base
  belongs_to :character, inverse_of: :character_roles
  belongs_to :series, inverse_of: :character_roles
  has_many :appearances, inverse_of: :character_role

  accepts_nested_attributes_for :appearances, allow_destroy: true

  attr_accessible :role_type, :character, :series, :appearances_attributes, :series_id

  ROLE_TYPES = [:major, :cameo].freeze

  validates :role_type, presence: true, inclusion: {in: ROLE_TYPES}
  validates :character_id, :series_id, presence: true

  scope :ordered, joins(:character, :series).merge(Character.ordered).merge(Series.ordered)

  def role_type
    (value = read_attribute(:role_type)) && value.to_sym
  end

  def role_type= value
    write_attribute(:role_type, value && value.to_s)
  end
end
