class Match < ActiveRecord::Base
  include Ordering

  attr_accessible :date, :group, :match_number, :stage, :tournament

  belongs_to :tournament, inverse_of: :matches
  has_many :match_entries, inverse_of: :match
  #Possibly link to next_match_entries here (inverse of previous_match in MatchEntry)

  has_many :appearances, through: :match_entries
  has_many :character_roles, through: :appearances
  has_many :voice_actor_roles, through: :appearances
  has_many :characters, through: :character_roles
  has_many :series, through: :character_roles, uniq: true
  has_many :voice_actors, through: :voice_actor_roles

  validates :group, group: true
  validates :stage, presence: true, stage: true, uniqueness: {scope: [:tournament_id, :group, :match_number]}
  validates :match_number, numericality: {only_integer: true}, allow_nil: true
  validates :date, :tournament_id, presence: true

  STAGE_ORDER = MatchInfo::STAGES.collect {|s| "#{q_column(:stage)} = '#{s}' DESC"}.freeze

  TOURNAMENT_ORDER = (STAGE_ORDER + [q_column(:group), q_column(:match_number), q_column(:date)]).freeze
  DATE_ORDER = ([q_column(:date)] + STAGE_ORDER + [q_column(:group), q_column(:match_number)]).freeze

  order_scope :ordered, TOURNAMENT_ORDER
  order_scope :ordered_by_date, DATE_ORDER

  def group
    (value = read_attribute(:group)) && value.to_sym
  end

  def group= value
    write_attribute(:group, value && value.to_s)
  end

  def stage
    (value = read_attribute(:stage)) && value.to_sym
  end

  def stage= value
    write_attribute(:stage, value && value.to_s)
  end

  def group_match?
    MatchInfo::GROUP_STAGES.include? stage
  end

  def final_match?
    MatchInfo::FINAL_STAGES.include? stage
  end

  def finished?
    match_entries.any? &:number_of_votes
  end

  def number_of_votes
    match_entries.sum :number_of_votes
  end

  def winning_match_entries
    return [] unless finished?
    match_entries.ordered_by_position.where(number_of_votes: match_entries.maximum(:number_of_votes))
  end

  def draw?
    winning_match_entries.size > 1
  end
end
