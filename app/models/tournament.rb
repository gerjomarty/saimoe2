require 'whereize'

class Tournament < ActiveRecord::Base
  include Ordering

  attr_accessible :year, :group_stages, :final_stages
  serialize :group_stages, Array
  serialize :final_stages, Array

  has_many :appearances, inverse_of: :tournament
  has_many :matches, inverse_of: :tournament

  validates :year, presence: true, uniqueness: true, format: {with: /\d{4}/}, length: {is: 4}
  validates :group_stages, presence: true, group_stage: true
  validates :final_stages, presence: true, final_stage: true

  ORDER = [q_column(:year)].freeze
  order_scope :ordered, ORDER

  def stages
    group_stages + final_stages
  end

  def self.fy year
    find_by_year year.to_s
  end

  def self.all_for model
    join_conds = case model
                   when Character  then {:appearances => {:character_role => :character}}
                   when Series     then {:appearances => {:character_role => :series}}
                   when VoiceActor then {:appearances => {:voice_actor_roles => :voice_actor}}
                 else
                   raise ArgumentError, "Invalid model passed to Tournament#all_for"
                 end

    joins(join_conds).where(Whereize.perform(join_conds, model)).ordered.uniq
  end
end
