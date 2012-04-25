class MatchEntry < ActiveRecord::Base
  attr_accessible :number_of_votes, :position, :match, :previous_match, :appearance

  belongs_to :match, inverse_of: :match_entries
  belongs_to :previous_match, class_name: 'Match', foreign_key: :previous_match_id
  belongs_to :appearance, inverse_of: :match_entries

  validates :match_id, presence: true
  validates :position, presence: true, numericality: {only_integer: true}
  validates :number_of_votes, numericality: {only_integer: true}, allow_nil: true
end
