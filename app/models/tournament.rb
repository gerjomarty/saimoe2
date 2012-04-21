class Tournament < ActiveRecord::Base
  attr_accessible :year, :group_stages, :final_stages
  serialize :group_stages, Array
  serialize :final_stages, Array

  has_many :appearances, inverse_of: :tournament
  has_many :matches, inverse_of: :tournament

  validates :year, presence: true, uniqueness: true, format: {with: /\d{4}/}, length: {is: 4}
  validates :group_stages, presence: true, group_stage: true
  validates :final_stages, presence: true, final_stage: true

  def self.fy year
    find_by_year year.to_s
  end
end
