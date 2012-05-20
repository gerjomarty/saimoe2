# Mixin with model
# Instance methods:
# * soulmate_term - the word to be searched on - required
# * soulmate_data - any extra data that you want to be available to the soulmate_label
# Class methods:
# * soulmate_label_for(id, term, data) - label to appear on the autocomplete box
module SoulmateSearch
  def self.included base
    base.extend ClassMethods
    base.after_save :load_into_soulmate
    base.before_destroy :delete_from_soulmate
  end

  def load_into_soulmate
    begin
      Soulmate::Loader.new(self.class.to_s).add('id' => self.id,
                                                'term' => self.soulmate_term,
                                                'data' => self.soulmate_data)
    rescue Errno::ECONNREFUSED => e
      Rails.logger.warn "Cannot contact Redis: #{e}"
    end
  end

  def delete_from_soulmate
    begin
      Soulmate::Loader.new(self.class.to_s).remove('id' => self.id)
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
    def soulmate_label_for id, term, data
      term
    end

    def search term
      Soulmate::Matcher.new(self.to_s).matches_for_term(term).collect do |m|
        {id: m['id'],
         value: m['term'],
         label: self.soulmate_label_for(m['id'], m['term'], m['data'])}
      end
    end
  end
end