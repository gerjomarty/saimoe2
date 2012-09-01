class MatchEntry < ActiveRecord::Base
  include Ordering

  attr_accessible :number_of_votes, :position, :match, :previous_match, :appearance

  belongs_to :match, inverse_of: :match_entries
  belongs_to :previous_match, class_name: 'Match', foreign_key: :previous_match_id
  belongs_to :appearance, inverse_of: :match_entries

  validates :match_id, presence: true
  validates :position, presence: true, numericality: {only_integer: true}
  validates :number_of_votes, numericality: {only_integer: true}, allow_nil: true

  POSITION_ORDER = [q_column(:position)].freeze
  VOTE_ORDER = ["#{q_column(:number_of_votes)} DESC", q_column(:position)].freeze

  order_scope :ordered_by_position, POSITION_ORDER
  order_scope :ordered_by_votes, VOTE_ORDER

  def winner?
    match.winning_match_entries.include? self
  end

  def vote_share
    self.number_of_votes && (self.number_of_votes.to_f / match.number_of_votes.to_f)
  end

  def character_name
    appearance.character_display_name || appearance.character_role.character.full_name
  end

  def series
    appearance.character_role.series
  end
end
