#!/usr/bin/env ruby

require File.expand_path('../../config/environment', __FILE__)

# Clear the current database

Soulmate.redis.flushall

Dir["#{Rails.root}/app/models/**/*.rb"].each do |file|
  begin
    require file
  rescue
  end
end

ActiveRecord::Base.descendants.select { |m|
  m.respond_to?(:search) && m.method_defined?(:soulmate_term) && m.method_defined?(:soulmate_data)
}.each do |model|
  begin
    model.find_each(model === Character ? {include: :main_series} : {}) do |record|
      record.load_into_soulmate
    end
  rescue Exception => e
    Rails.logger.fatal "Error when generating Soulmate keys: #{e}"
  end
end