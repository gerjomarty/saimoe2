class Series < ActiveRecord::Base
  attr_accessible :color_code, :name

  validates :name, presence: true
  validates :color_code, format: {with: /[\dA-Fa-f]{6}/}, length: {is: 6}, allow_nil: true

  def color_code= code
    write_attribute(:color_code, code.presence && code.presence.to_s.upcase)
  end
end
