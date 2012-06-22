require 'soulmate_search'

class Series < ActiveRecord::Base
  include SoulmateSearch
  extend FriendlyId

  attr_accessible :color_code, :name

  before_validation :generate_sortable_name

  has_many :main_characters, class_name: 'Character', inverse_of: :main_series, foreign_key: :main_series_id
  has_many :character_roles, inverse_of: :series

  validates :name, :sortable_name, presence: true
  validates :slug, presence: true, uniqueness: {case_sensitive: false}
  validates :color_code, format: {with: /[\dA-Fa-f]{6}/}, length: {is: 6}, allow_nil: true

  ORDER = [q_column(:sortable_name)].freeze
  scope :ordered, ORDER.inject(nil) {|memo, n| memo ? memo.order(n) : order(n) }

  friendly_id :sortable_name, use: [:slugged, :history]

  def color_code= code
    write_attribute(:color_code, code && code.to_s.upcase)
  end

  def tournament_history
    {}.tap do |th|
      Tournament.all_for(self).each do |t|
        th[t] ||= {}
        t.matches.all_for(self).each do |m|
          th[t][m.stage] ||= []
          th[t][m.stage] += m.match_entries.all_for(self)
        end
      end
    end
  end

  # Soulmate methods

  def soulmate_term
    self.name
  end

  private

  def generate_sortable_name
    self.sortable_name = self.name.sub(/^the\s+/i, '') if self.name
  end
end
