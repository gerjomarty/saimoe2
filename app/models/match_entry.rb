class MatchEntry < ActiveRecord::Base
  attr_accessible :number_of_votes, :position

  belongs_to :match, inverse_of: :match_entries
  belongs_to :previous_match, class_name: 'Match', foreign_key: :previous_match_id
  belongs_to :appearance, inverse_of: :match_entries

  validates :position, :match_id, presence: true, numericality: {only_integer: true}
  validates :number_of_votes, :previous_match_id, :appearance_id, numericality: {only_integer: true}
end
