require 'soulmate_search'

class Series < ActiveRecord::Base
  include SoulmateSearch
  include Ordering
  extend FriendlyId

  attr_accessible :color_code, :name

  before_validation :generate_sortable_name

  mount_uploader :image, SeriesImageUploader

  has_many :main_characters, class_name: 'Character', inverse_of: :main_series, foreign_key: :main_series_id
  has_many :character_roles, inverse_of: :series

  has_many :characters, through: :character_roles
  has_many :appearances, through: :character_roles
  has_many :tournaments, through: :appearances, uniq: true
  has_many :match_entries, through: :appearances
  has_many :voice_actor_roles, through: :appearances
  has_many :matches, through: :match_entries, uniq: true
  has_many :voice_actors, through: :voice_actor_roles

  validates :name, :sortable_name, presence: true
  validates :slug, presence: true, uniqueness: {case_sensitive: false}
  validates :color_code, format: {with: /[\dA-Fa-f]{6}/}, length: {is: 6}, allow_nil: true

  ORDER = [q_column(:sortable_name)].freeze
  order_scope :ordered, ORDER

  friendly_id :sortable_name, use: [:slugged, :history]

  def to_s
    name
  end

  def color_code= code
    write_attribute(:color_code, code && code.to_s.upcase)
  end

  # Soulmate methods

  def soulmate_term
    self.name
  end

  def self.soulmate_category
    'Series'
  end

  def self.soulmate_target_path
    Rails.application.routes.url_helpers.series_index_path
  end

  private

  def generate_sortable_name
    self.sortable_name = self.name.sub(/^the\s+/i, '') if self.name
  end
end
