class Character < ActiveRecord::Base
  attr_accessible :first_name, :given_name, :last_name

  validate :name_present

  scope :characters_for_name, lambda {|name| where(self.name_query(name)) }
  scope :find_by_name, lambda {|name| characters_for_name(name).first }
  scope :find_all_by_name, lambda {|name| characters_for_name(name).all }

  def full_name
    if self.first_name && self.last_name
      "#{self.first_name} #{self.last_name}"
    else
      self.first_name || self.last_name || self.given_name
    end
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