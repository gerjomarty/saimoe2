# Load the rails application
require File.expand_path('../application', __FILE__)

require File.expand_path('../../lib/foreign_key_migration', __FILE__)
require File.expand_path('../../lib/nullify_blank_attributes', __FILE__)
require File.expand_path('../../lib/column_methods', __FILE__)

ENV['SECRET_TOKEN'] = File.read File.expand_path('../../lib/data/secret_token', __FILE__) unless Rails.env.production?

# Initialize the rails application
Saimoe2::Application.initialize!
