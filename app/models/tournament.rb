class Tournament < ActiveRecord::Base
  attr_accessible :year

  validates :year, presence: true, uniqueness: true, format: {with: /\d{4}/}, length: {is: 4}

  def self.fy year
    find_by_year year.to_s
  end
end
