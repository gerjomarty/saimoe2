class Match < ActiveRecord::Base
  attr_accessible :date, :group, :match_number, :stage

  belongs_to :tournament, inverse_of: :matches
  has_many :match_entries, inverse_of: :match
  #Possibly link to next_match_entries here (inverse of previous_match in MatchEntry)

  GROUP_STAGES = %w{round_1 round_1_playoff round_2 round_2_playoff round_3 group_final}.collect(&:to_sym).freeze
  FINAL_STAGES = %w{last_16 quarter_final semi_final final}.collect(&:to_sym).freeze
  STAGES = (GROUP_STAGES + FINAL_STAGES).freeze

  validates :group, presence: true, length: {is: 1}, format: {with: /\w/},
                    if: Proc.new {|m| GROUP_STAGES.include? m.stage}
  validates :group, inclusion: {in: [nil], message: "must be nil for a final match"},
                    if: Proc.new {|m| FINAL_STAGES.include? m.stage}
  validates :stage, presence: true, inclusion: {in: STAGES},
                    uniqueness: {scope: [:tournament_id, :group, :match_number]}
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
end
