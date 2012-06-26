require 'soulmate_search'

class VoiceActor < ActiveRecord::Base
  include SoulmateSearch
  include Ordering
  extend FriendlyId

  attr_accessible :first_name, :last_name

  has_many :voice_actor_roles, inverse_of: :voice_actor

  validates :slug, presence: true, uniqueness: {case_sensitive: false}
  validate :name_present

  ORDER = ["(#{q_column :last_name} IS NOT NULL)",
           "(#{q_column :last_name} IS NULL)", q_column(:last_name),
           "(#{q_column :first_name} IS NULL)", q_column(:first_name)].freeze
  order_scope :ordered, ORDER

  friendly_id :full_name, use: [:slugged, :history]

  def full_name
    if self.first_name && self.last_name
      "#{self.first_name} #{self.last_name}"
    else
      self.first_name || self.last_name
    end
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
    self.full_name
  end

  private

  def name_present
    unless self.first_name || self.last_name
      errors.add :base, "At least one name must be given"
    end
  end
end
