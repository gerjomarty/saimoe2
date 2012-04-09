class Series < ActiveRecord::Base
  attr_accessible :color_code, :name

  has_many :main_characters, class_name: 'Character', inverse_of: :main_series, foreign_key: :main_series_id
  has_many :character_roles, inverse_of: :series

  validates :name, presence: true
  validates :color_code, format: {with: /[\dA-Fa-f]{6}/}, length: {is: 6}, allow_nil: true

  def color_code= code
    write_attribute(:color_code, code && code.to_s.upcase)
  end
end
