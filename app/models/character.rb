class Character < ActiveRecord::Base
  attr_accessible :first_name, :given_name, :last_name, :main_series

  belongs_to :main_series, class_name: 'Series', inverse_of: :main_characters, foreign_key: :main_series_id
  has_many :character_roles, inverse_of: :character

  validates :main_series_id, presence: true
  validate :name_present

  scope :characters_for_name, lambda {|name| where(self.name_query(name)) }

  def full_name
    if self.first_name && self.last_name
      "#{self.first_name} #{self.last_name}"
    else
      self.first_name || self.last_name || self.given_name
    end
  end

  def self.find_by_name name
    characters_for_name(name).first
  end

  def self.find_all_by_name name
    characters_for_name(name).all
  end

  def self.find_by_name_and_series name, series
    characters_for_name(name).joins(:character_roles)
    .where(:character_roles => {series_id: series && series.id}).first
  end

  private

  def name_present
    unless self.first_name || self.last_name || self.given_name
      errors.add :base, "At least one name must be given"
    end
  end

  def self.name_parts name
    name = name.to_s
    return if name.empty?
    parts = name.split(/ /)
    size = parts.size
    return [] if size == 1
    (0...size).collect {|i| [parts[0...i].join(' '), parts[i...size].join(' ')] }[1..-1].each do |p|
      yield p[0], p[1] if block_given?
    end
  end

  def self.name_query name
    ct = self.arel_table
    query = self.name_parts(name).inject(nil) do |result, names|
      q = ct[:first_name].eq(names.first).and(ct[:last_name].eq(names.last))
      result ? result.or(q) : q
    end

    fields = [:first_name, :last_name, :given_name]
    fields.inject(query) do |result, field|
      nil_fields = fields - [field]
      q = ct[field].eq(name).and(ct[nil_fields.first].eq(nil)).and(ct[nil_fields.last].eq(nil))
      result ? result.or(q) : q
    end
  end
end
