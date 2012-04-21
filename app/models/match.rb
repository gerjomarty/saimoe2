class Match < ActiveRecord::Base
  attr_accessible :date, :group, :match_number, :stage

  belongs_to :tournament, inverse_of: :matches
  has_many :match_entries, inverse_of: :match
  #Possibly link to next_match_entries here (inverse of previous_match in MatchEntry)

  validates :group, presence: true, group: true
  validates :stage, presence: true, stage: true, uniqueness: {scope: [:tournament_id, :group, :match_number]}
  validates :match_number, numericality: {only_integer: true}
  validates :date, presence: true
  validates :tournament_id, presence: true, numericality: {only_integer: true}

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
end
