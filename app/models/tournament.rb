class Tournament < ActiveRecord::Base
  include Ordering

  attr_accessible :year, :group_stages, :final_stages
  serialize :group_stages, Array
  serialize :final_stages, Array

  has_many :appearances, inverse_of: :tournament
  has_many :matches, inverse_of: :tournament

  has_many :character_roles, through: :appearances
  has_many :voice_actor_roles, through: :appearances
  has_many :characters, through: :character_roles
  has_many :series, through: :character_roles, uniq: true
  has_many :voice_actors, through: :voice_actor_roles, uniq: true

  validates :year, presence: true, uniqueness: true, format: {with: /\d{4}/}, length: {is: 4}
  validates :group_stages, presence: true, group_stage: true
  validates :final_stages, presence: true, final_stage: true

  ORDER = [q_column(:year)].freeze
  order_scope :ordered, ORDER

  def group_stages_without_playoffs
    group_stages - MatchInfo::PLAYOFF_STAGES
  end

  def playoff_group_stages
    group_stages & MatchInfo::PLAYOFF_STAGES
  end

  # Final stages don't have play off stages at the moment

  def groups
    matches.group_matches.select(Match.q_column :group).uniq.collect(&:group).sort
  end

  def stages
    group_stages + final_stages
  end

  def self.fy year
    find_by_year year.to_s
  end

  def currently_on?
    matches.any? {|m| !m.is_finished? }
  end

  def most_recent_match_date
    matches.where(is_finished: true).maximum(Match.q_column :date).to_date
  end
end
