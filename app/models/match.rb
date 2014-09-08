class Match < ActiveRecord::Base
  include Ordering

  mount_uploader :vote_graph, VoteGraphUploader

  attr_accessible :date, :group, :match_number, :stage, :tournament, :is_finished, :is_winner, :number_of_votes,
                  :is_draw, :vote_graph_cache, :remote_vote_graph_url, :remove_vote_graph, :vote_graph

  belongs_to :tournament, inverse_of: :matches, touch: true
  has_many :match_entries, inverse_of: :match
  has_many :next_match_entries, inverse_of: :previous_match, class_name: 'MatchEntry', foreign_key: :previous_match_id

  has_many :appearances, through: :match_entries
  has_many :character_roles, through: :appearances
  has_many :voice_actor_roles, through: :appearances
  has_many :characters, through: :character_roles
  has_many :series, through: :character_roles, uniq: true
  has_many :voice_actors, through: :voice_actor_roles, uniq: true

  validates :group, group: true
  validates :stage, presence: true, stage: true, uniqueness: {scope: [:tournament_id, :group, :match_number]}
  validates :match_number, :number_of_votes, numericality: {only_integer: true}, allow_nil: true
  validates :date, :tournament_id, presence: true
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
    MatchInfo::PLAYOFF_STAGES.include? stage
  end

  def playoff_group?
    MatchInfo::PLAYOFF_GROUPS.include? group
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

  # Returns an array of match entry counts for the matches below this one in the hierarchy
  def base_match_entry_counts allow_playoff_groups=false
    match_hierarchy(allow_playoff_groups).leaf_nodes.reject(&:zero?)
  end

  # This method is mostly for working out how tall elements on the tournament show page
  # need to be. It takes a toll on the database, so don't do it often.
  def match_hierarchy allow_playoff_groups=false
    if (prev_matches = match_entries
                       .includes(:previous_match => {:match_entries => :previous_match})
                       .ordered_by_position
                       .collect(&:previous_match).compact.uniq).empty?
      if allow_playoff_groups
        {self => self.playoff_match? && !self.playoff_group? ? 0 : match_entries.count}
      else
        {self => self.playoff_match? || self.playoff_group? ? 0 : match_entries.count}
      end
    else
      {self => prev_matches.collect {|m| m.match_hierarchy(allow_playoff_groups) }.inject(&:merge)}
    end
  end

  def self.date_before date
    select(q_column :date).uniq.order("#{q_column :date} DESC").where("#{q_column :date} < ?", date).first.try(:date)
  end

  def self.date_after date
    select(q_column :date).uniq.order(q_column :date).where("#{q_column :date} > ?", date).first.try(:date)
  end

  def self.most_recent_finish_date
    where(is_finished: true).maximum(q_column :date).to_date
  end

  def pretty length=:long
    case length
    when :long
      case stage
      when :final                                then 'Grand Final'
      when :semi_final, :quarter_final, :last_16 then "#{pretty_stage} #{match_number}"
      when :group_final                          then "#{pretty_group} Final"
      else
        if [:losers_playoff, :losers_playoff_single].include? group
          "#{pretty_stage} Match #{match_number}".chomp(' Match ')
        else
          "#{pretty_stage} Match #{pretty_group(:short)}#{match_number}"
        end
      end
    when :short
      case stage
      when :final                  then 'Final'
      when :semi_final             then "SF #{match_number}"
      when :quarter_final          then "QF #{match_number}"
      when :last_16                then "L16 #{match_number}"
      when :losers_playoff_finals  then "LP Final #{match_number}"
      when :losers_playoff_round_2 then "LP R2 #{match_number}"
      when :losers_playoff_round_1 then "LP R1 #{match_number}"
      when :group_final            then "#{pretty_group(:short)} Final"
      when :round_3                then "R3 #{pretty_group(:short)}#{match_number}"
      when :round_2_playoff        then "R2P #{pretty_group(:short)}#{match_number}"
      when :round_2                then "R2 #{pretty_group(:short)}#{match_number}"
      when :round_1_playoff        then "R1P #{pretty_group(:short)}#{match_number}"
      when :round_1                then "R1 #{pretty_group(:short)}#{match_number}"
      else                              "#{pretty_group(:short)}#{match_number}"
      end
    end
  end

  def pretty_stage
    MatchInfo.pretty_stage stage
  end

  def pretty_group length=:long
    return '' unless group
    MatchInfo.pretty_group group, length
  end

  private

  def validate_match_entries_finished
    if is_finished?
      errors.add :base, "Not all match entries have vote counts" unless match_entries.all? {|me| me.number_of_votes}
    end
  end
end
