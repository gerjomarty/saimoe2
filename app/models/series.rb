class Series < ActiveRecord::Base
  extend FriendlyId

  attr_accessible :color_code, :name

  has_many :main_characters, class_name: 'Character', inverse_of: :main_series, foreign_key: :main_series_id
  has_many :character_roles, inverse_of: :series

  validates :name, presence: true
  validates :slug, presence: true, uniqueness: {case_sensitive: false}
  validates :color_code, format: {with: /[\dA-Fa-f]{6}/}, length: {is: 6}, allow_nil: true

  ORDER = [q_column(:name)].freeze
  scope :ordered, ORDER.inject(nil) {|memo, n| memo ? memo.order(n) : order(n) }

  friendly_id :name, use: [:slugged, :history]

  def color_code= code
    write_attribute(:color_code, code && code.to_s.upcase)
  end
end
