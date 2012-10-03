class Match < ActiveRecord::Base
  include Ordering

  attr_accessible :date, :group, :match_number, :stage, :tournament, :is_finished, :is_winner, :number_of_votes, :is_draw, :table_height

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
  validates :match_number, :number_of_votes, numericality: {only_integer: true}, allow_nil: true
  validates :date, :tournament_id, presence: true
  validates :table_height, numericality: true, allow_nil: true
  validate :validate_match_entries_finished

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

  def is_finished= finished
    ret = write_attribute :is_finished, finished
    if finished
      self.number_of_votes = self.number_of_votes
      match_entries.each {|me| me.is_finished = true; me.save!}
      self.is_draw = self.is_draw
    else
      self.number_of_votes = self.is_draw = nil
      match_entries.each {|me| me.is_finished = false; me.save!}
    end
    self.table_height = nil
    self.table_height = self.table_height
    ret
  end

  def number_of_votes
    value = read_attribute :number_of_votes
    return value unless value.nil?

    match_entries.sum :number_of_votes
  end

  def winning_match_entries
    return [] unless is_finished?

    match_entries.ordered_by_position.where(is_winner: true)
  end

  def is_draw
    value = read_attribute :is_draw
    return value unless value.nil?

    winning_match_entries.size > 1
  end

  def table_height
    value = read_attribute :table_height
    return value unless value.nil?

    match_hierarchy.sum_leaf_nodes.to_f
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

  def self.date_before date
    select(q_column :date).uniq.order("#{q_column :date} DESC").where("#{q_column :date} < ?", date).first.try(:date)
  end

  def self.date_after date
    select(q_column :date).uniq.order(q_column :date).where("#{q_column :date} > ?", date).first.try(:date)
  end

  private

  def validate_match_entries_finished
    if is_finished?
      errors.add :base, "Not all match entries have vote counts" unless match_entries.all? {|me| me.number_of_votes}
    end
  end
end
