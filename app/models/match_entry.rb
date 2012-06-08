require 'whereize'

class MatchEntry < ActiveRecord::Base
  attr_accessible :number_of_votes, :position, :match, :previous_match, :appearance

  belongs_to :match, inverse_of: :match_entries
  belongs_to :previous_match, class_name: 'Match', foreign_key: :previous_match_id
  belongs_to :appearance, inverse_of: :match_entries

  validates :match_id, presence: true
  validates :position, presence: true, numericality: {only_integer: true}
  validates :number_of_votes, numericality: {only_integer: true}, allow_nil: true

  POSITION_ORDER = [q_column(:position)].freeze
  VOTE_ORDER = ["#{q_column(:number_of_votes)} DESC", q_column(:position)].freeze

  [[:ordered_by_position, POSITION_ORDER], [:ordered_by_votes, VOTE_ORDER]].each do |scope_name, order|
    scope scope_name, order.inject(nil) {|memo, n| memo ? memo.order(n) : order(n) }
  end

  def winner?
    match.winning_match_entries.include? self
  end

  def vote_share
    self.number_of_votes && (self.number_of_votes.to_f / match.number_of_votes.to_f)
  end

  #th[t][m.stage][:match_entry] = m.match_entries.joins(:appearance => {:character_role => :character})
  #.where(:appearances => {:character_roles => {:characters => {id: self.id}}}).first!

  def self.all_for model
    join_conds = case model
                   when Character  then {:appearance => {:character_role => :character}}
                   when Series     then {:appearance => {:character_role => :series}}
                   when VoiceActor then {:appearance => {:voice_actor_roles => :voice_actor}}
                 else
                   raise ArgumentError, "Invalid model passed to MatchEntry#all_for"
                 end

    joins(join_conds).where(Whereize.perform(join_conds, model)).ordered_by_votes
  end
end
