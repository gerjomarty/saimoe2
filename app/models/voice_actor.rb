require 'soulmate_search'

class VoiceActor < ActiveRecord::Base
  include SoulmateSearch
  include Ordering
  extend FriendlyId

  attr_accessible :first_name, :last_name

  has_many :voice_actor_roles, inverse_of: :voice_actor

  has_many :appearances, through: :voice_actor_roles
  has_many :tournaments, through: :appearances, uniq: true
  has_many :character_roles, through: :appearances
  has_many :match_entries, through: :appearances
  has_many :characters, through: :character_roles, uniq: true
  has_many :series, through: :character_roles, uniq: true
  has_many :matches, through: :match_entries, uniq: true

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

  def to_s
    full_name
  end

  def tournament_history
    {}.tap do |th|
      match_entries.includes(:match => :tournament).merge(Tournament.ordered).each do |me|
        match = me.match
        tournament = match.tournament

        th[tournament] ||= {}
        th[tournament][match.stage] ||= []
        th[tournament][match.stage] << me
      end
    end
  end

  # Soulmate methods

  def soulmate_term
    self.full_name
  end

  def self.soulmate_category
    'Voice Actors'
  end

  def self.soulmate_target_path
    Rails.application.routes.url_helpers.voice_actors_path
  end

  private

  def name_present
    unless self.first_name || self.last_name
      errors.add :base, "At least one name must be given"
    end
  end
end
