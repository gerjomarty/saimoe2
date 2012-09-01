class Match < ActiveRecord::Base
  include Ordering

  attr_accessible :date, :group, :match_number, :stage, :tournament

  belongs_to :tournament, inverse_of: :matches
  has_many :match_entries, inverse_of: :match
  has_many :next_match_entries, inverse_of: :previous_match, class_name: 'MatchEntry', foreign_key: :previous_match_id

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

  scope :without_playoffs, where("#{q_column(:stage)} NOT IN (?)", MatchInfo::PLAYOFF_STAGES)
                           .where("#{q_column(:group)} NOT IN (?)", MatchInfo::PLAYOFF_GROUPS)
  scope :with_only_playoffs, where(stage: MatchInfo::PLAYOFF_STAGES)
  scope :group_matches, where(stage: MatchInfo::GROUP_STAGES)
  scope :final_matches, where(stage: MatchInfo::FINAL_STAGES)

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

  def playoff_match?
    MatchInfo::PLAYOFF_STAGES.include?(stage) || MatchInfo::PLAYOFF_GROUPS.include?(group)
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

  # This method is mostly for working out how tall elements on the tournament show page
  # need to be. It takes a toll on the database, so don't do it often.
  def match_hierarchy
    if (prev_matches = match_entries
                       .includes(:previous_match => {:match_entries => :previous_match})
                       .ordered_by_position
                       .collect(&:previous_match).compact.uniq).empty?
      {self => self.playoff_match? ? 0 : match_entries.count}
    else
      {self => prev_matches.collect(&:match_hierarchy).inject(&:merge)}
    end
  end
end
