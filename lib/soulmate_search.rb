# Mixin with model

# Instance methods:
# * soulmate_term - the word to be searched on - required
# * soulmate_data - any extra data that you want to be available to the soulmate_label

# Class methods:
# * soulmate_label_for(id, term, data) - label to appear on the autocomplete box
# * soulmate_category - the category name that appears in the autocomplete box
# * soulmate_target_path - the path that precedes /:id that leads to the selected entry - required

module SoulmateSearch
  def self.included base
    base.extend ClassMethods
    base.after_save :load_into_soulmate
    base.before_destroy :delete_from_soulmate
  end

  def load_into_soulmate
    begin
      self.class.loader.add('id' => self.id, 'term' => self.soulmate_term, 'data' => self.soulmate_data)
    rescue Errno::ECONNREFUSED => e
      Rails.logger.warn "Cannot contact Redis: #{e}"
    end
  end

  def delete_from_soulmate
    begin
      self.class.loader.remove('id' => self.id)
    rescue Errno::ECONNREFUSED => e
      Rails.logger.warn "Cannot contact Redis: #{e}"
    end
  end

  def soulmate_term
    raise NotImplementedError, "soulmate_term needs to be overridden by the subclass"
  end

  def soulmate_data
    {}
  end

  module ClassMethods
    attr_reader :loader, :matcher

    def loader
      @loader ||= Soulmate::Loader.new(self.to_s)
    end

    def matcher
      @matcher ||= Soulmate::Matcher.new(self.to_s)
    end

    def soulmate_label_for id, term, data
      term
    end

    def soulmate_category
      nil
    end

    def soulmate_target_path
      raise NotImplementedError, "soulmate_target_path needs to be overridden by the subclass"
    end

    def search term
      options = {cache: !Rails.env.test?}
      self.matcher.matches_for_term(term, options).collect do |m|
        {
          id: m['id'],
          value: m['term'],
          label: self.soulmate_label_for(m['id'], m['term'], m['data']),
          target_path: self.soulmate_target_path,
          category: self.soulmate_category
        }
      end
    end
  end
end