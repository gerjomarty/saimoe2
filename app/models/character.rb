require 'soulmate_search'

class Character < ActiveRecord::Base
  include SoulmateSearch
  extend FriendlyId

  attr_accessible :first_name, :given_name, :last_name, :main_series

  mount_uploader :avatar, AvatarUploader

  belongs_to :main_series, class_name: 'Series', inverse_of: :main_characters, foreign_key: :main_series_id
  has_many :character_roles, inverse_of: :character

  validates :main_series_id, presence: true
  validates :slug, presence: true, uniqueness: {case_sensitive: false}
  validate :name_present

  scope :characters_for_name, lambda {|name| where(self.name_query(name)) }

  ORDER = ["(#{q_column :last_name} IS NOT NULL OR #{q_column :given_name} IS NOT NULL)",
           "(#{q_column :last_name} IS NULL)", q_column(:last_name),
           "(#{q_column :first_name} IS NULL)", q_column(:first_name),
           "(#{q_column :given_name} IS NULL)", q_column(:given_name)].freeze
  scope :ordered, ORDER.inject(nil) {|memo, n| memo ? memo.order(n) : order(n) }

  scope :ordered_by_main_series, includes(:main_series).merge(Series.ordered).ordered

  friendly_id :slug_parts, use: [:slugged, :history]

  def full_name
    if self.first_name && self.last_name
      "#{self.first_name} #{self.last_name}"
    else
      self.first_name || self.last_name || self.given_name
    end
  end

  def other_series
    Series.joins(:character_roles => :character)
          .where(:character_roles => {character_id: self.id})
          .where("#{Series.q_column(:id)} <> ?", self.main_series_id).ordered.uniq
  end

  def voice_actors
    VoiceActor.joins(:voice_actor_roles => {:appearance => {:character_role => :character}})
              .where(:character_roles => {character_id: self.id})
              .ordered.all.uniq
  end

  def tournament_history
    {}.tap do |th|
      Tournament.all_for(self).each do |t|
        th[t] ||= {}
        t.matches.all_for(self).each do |m|
          th[t][m.stage] ||= {}
          th[t][m.stage][:match] = m
          th[t][m.stage][:match_entry] = m.match_entries.all_for(self).first!
        end
      end
    end

  end

  # If there are any name clashes, we want the slugs to be appended with their main
  # series name rather than just a number sequence.
  # This assumes there won't be any characters that have the same name *and* series.
  def normalize_friendly_id parts
    slug = super(parts[:full_name])
    sep = self.friendly_id_config.sequence_separator

    dups = self.class.where("LOWER(slug) = LOWER(?) OR LOWER(slug) LIKE LOWER(?)", slug, "#{slug}#{sep}%")
    dups = dups.where("id <> ?", parts[:id]) unless parts[:new_record]

    slug << "#{sep}#{super(Series.find(parts[:main_series_id]).name)}" if dups.any?
    slug
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

  # Soulmate methods

  def soulmate_term
    self.full_name
  end

  def soulmate_data
    {'s' => self.main_series.name}
  end

  def self.soulmate_label_for id, term, data
    "#{term} (#{data['s']})"
  end

  private

  def name_present
    unless self.first_name || self.last_name || self.given_name
      errors.add :base, "At least one name must be given"
    end
  end

  def slug_parts
    {id: self.id, main_series_id: self.main_series_id,
     new_record: self.new_record?, full_name: self.full_name}
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
