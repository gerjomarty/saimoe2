# Load the rails application
require File.expand_path('../application', __FILE__)

require 'foreign_key_migration'
require 'nullify_blank_attributes'
require 'column_methods'
require 'ordering'

# Initialize the rails application
Saimoe2::Application.initialize!
