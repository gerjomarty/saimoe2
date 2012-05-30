#!/usr/bin/env ruby

require File.expand_path('../../config/environment', __FILE__)

Dir["#{Rails.root}/app/models/**/*.rb"].each do |file|
  begin
    require file
  rescue
  end
end

ActiveRecord::Base.descendants.select do |m|
  m.respond_to?(:search) && m.method_defined?(:soulmate_term) && m.method_defined?(:soulmate_data)
end.each do |model|
  begin
    model.find_each {|record| record.load_into_soulmate}
  rescue
    Rails.logger.fatal "Error when generating Soulmate keys: #{$!}"
  end
end