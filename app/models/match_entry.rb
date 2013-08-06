class MatchEntry < ActiveRecord::Base
  include Ordering

  attr_accessible :number_of_votes, :position, :match, :previous_match, :appearance, :is_finished, :is_winner, :vote_share, :character_name

  belongs_to :match, inverse_of: :match_entries, touch: true
  belongs_to :previous_match, class_name: 'Match', foreign_key: :previous_match_id, inverse_of: :next_match_entries, touch: true
  belongs_to :appearance, inverse_of: :match_entries, touch: true

  has_one :tournament, through: :match

  validates :match_id, presence: true
  validates :position, presence: true, numericality: {only_integer: true}
  validates :number_of_votes, numericality: {only_integer: true}, allow_nil: true
  validates :vote_share, numericality: {greater_than_or_equal_to: 0.0, less_than_or_equal_to: 1.0}, allow_nil: true

  POSITION_ORDER = [q_column(:position)].freeze
  VOTE_ORDER = ["#{q_column(:number_of_votes)} DESC", q_column(:position)].freeze

  order_scope :ordered_by_position, POSITION_ORDER
  order_scope :ordered_by_votes, VOTE_ORDER

  scope :finished, where(finished: true)
  scope :with_rank, select("rank() OVER (ORDER BY #{q_column :number_of_votes} DESC)")

  def is_finished= finished
    write_attribute :is_finished, finished
    if finished
      self.is_winner = self.is_winner
      self.vote_share = self.vote_share
    else
      self.is_winner = self.vote_share = nil
    end
    self.character_name = nil
    self.character_name = self.character_name
  end

  def is_winner
    value = read_attribute :is_winner
    return value unless value.nil?

    return false unless is_finished?
    match.match_entries.where(number_of_votes: match.match_entries.maximum(:number_of_votes)).include? self
  end

  def vote_share
    value = read_attribute :vote_share
    return value unless value.nil?

    return nil unless is_finished?
    self.number_of_votes.to_f / match.number_of_votes.to_f
  end

  def character_name
    value = read_attribute :character_name
    return value unless value.nil?

    appearance && (appearance.character_display_name || appearance.character_role.character.full_name)
  end

  def avatar
    return appearance.character_avatar if appearance && appearance.character_avatar?
    return character.avatar if character
    nil
  end

  def avatar?
    return true if appearance && appearance.character_avatar?
    character && character.avatar?
  end

  def character
    appearance.try(:character_role).try(:character)
  end

  def series
    appearance.try(:character_role).try(:series)
  end
end
