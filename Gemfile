source 'https://rubygems.org'

gem 'rails', '= 3.2.6'
gem 'pg'
gem 'thin'
gem 'dalli'
gem 'friendly_id', '~> 4.0.0'
gem 'soulmate', '~> 0.1.0'

# carrierwave gems
gem 'carrierwave', '~> 0.6.0'
gem 'fog'
gem 'mime-types'
gem 'rmagick'

group :assets do
  gem 'coffee-rails', '~> 3.2.1'
  gem 'jquery-rails', '~> 2.0.0'
  gem 'jquery-ui-rails', '~> 1.0.0'
  gem 'twitter-bootstrap-rails', '~> 2.1.0'
  gem 'uglifier', '>= 1.0.3'
end

group :test, :development do
  gem 'rspec-rails', '~> 2.10.0'
end

group :test do
  gem 'rake'
  gem 'factory_girl_rails', '~> 3.5.0'
  gem 'acts_as_fu', '~> 0.0.0', require: false
  gem 'mocha', '~> 0.11.0'
  gem 'shoulda-matchers', '~> 1.2.0'
  gem 'simplecov', '~> 0.6.0', require: false
end

group :development do
  gem 'heroku'
  gem 'ruby-debug19', require: 'ruby-debug'
end

group :production do
  gem 'newrelic_rpm'
end

# To use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'

# To use Jbuilder templates for JSON
# gem 'jbuilder'
