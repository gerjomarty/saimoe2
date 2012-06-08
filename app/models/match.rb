require 'whereize'

class Match < ActiveRecord::Base
  attr_accessible :date, :group, :match_number, :stage, :tournament

  belongs_to :tournament, inverse_of: :matches
  has_many :match_entries, inverse_of: :match
  #Possibly link to next_match_entries here (inverse of previous_match in MatchEntry)

  validates :group, group: true
  validates :stage, presence: true, stage: true, uniqueness: {scope: [:tournament_id, :group, :match_number]}
  validates :match_number, numericality: {only_integer: true}, allow_nil: true
  validates :date, :tournament_id, presence: true

  STAGE_ORDER = MatchInfo::STAGES.collect {|s| "#{q_column(:stage)} = '#{s}' DESC"}.freeze

  TOURNAMENT_ORDER = (STAGE_ORDER + [q_column(:group), q_column(:match_number), q_column(:date)]).freeze
  DATE_ORDER = ([q_column(:date)] + STAGE_ORDER + [q_column(:group), q_column(:match_number)]).freeze

  [[:ordered, TOURNAMENT_ORDER], [:ordered_by_date, DATE_ORDER]].each do |scope_name, order|
    scope scope_name, order.inject(nil) {|memo, n| memo ? memo.order(n) : order(n) }
  end

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
    match_entries.any?(&:number_of_votes)
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

  def self.all_for model
    join_conds = case model
                   when Character  then {:match_entries => {:appearance => {:character_role => :character}}}
                   when Series     then {:match_entries => {:appearance => {:character_role => :series}}}
                   when VoiceActor then {:match_entries => {:appearance => {:voice_actor_roles => :voice_actor}}}
                 else
                   raise ArgumentError, "Invalid model passed to Match#all_for"
                 end

    joins(join_conds).where(Whereize.perform(join_conds, model)).ordered
  end
end
