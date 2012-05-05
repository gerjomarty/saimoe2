class VoiceActor < ActiveRecord::Base
  attr_accessible :first_name, :last_name

  has_many :voice_actor_roles, inverse_of: :voice_actor

  validate :name_present

  ORDER = ["(#{q_column :last_name} IS NOT NULL)",
           "(#{q_column :last_name} IS NULL)", q_column(:last_name),
           "(#{q_column :first_name} IS NULL)", q_column(:first_name)].freeze
  scope :ordered, ORDER.inject(nil) {|memo, n| memo ? memo.order(n) : order(n) }

  def full_name
    if self.first_name && self.last_name
      "#{self.first_name} #{self.last_name}"
    else
      self.first_name || self.last_name
    end
  end

  private

  def name_present
    unless self.first_name || self.last_name
      errors.add :base, "At least one name must be given"
    end
  end
end
