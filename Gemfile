source 'https://rubygems.org'

gem 'rails', '= 3.2.11'
gem 'pg'
gem 'thin'
gem 'friendly_id', '~> 4.0.9'
gem 'soulmate', '~> 0.1.0'
gem 'nested_form', '~> 0.3.0'
gem 'google-analytics-rails'
gem 'rack-canonical-host', '~> 0.0.0'
gem 'cache_digests'

# memcache gems
gem 'dalli'
gem 'memcachier'

# carrierwave gems
gem 'carrierwave', '~> 0.8.0'
gem 'fog'
gem 'mime-types'
gem 'rmagick'

gem 'twitter-bootstrap-rails', '~> 2.2.0'
group :assets do
  gem 'coffee-rails', '~> 3.2.1'
  gem 'jquery-rails', '~> 2.2.0'
  gem 'jquery-ui-rails', '~> 3.0.0'
  gem 'uglifier', '>= 1.0.3'

  # twitter-bootstrap-rails gems
  gem 'therubyracer'
  gem 'less-rails'
end

group :test, :development do
  gem 'rspec-rails', '~> 2.12.0'
end

group :test do
  gem 'rake'
  gem 'factory_girl_rails', '~> 4.2.0'
  gem 'acts_as_fu', '~> 0.0.0', require: false
  gem 'mocha', '~> 0.13.0', require: false
  gem 'shoulda-matchers', '~> 1.4.0'
  gem 'simplecov', '~> 0.7.0', require: false
end

group :development do
  gem 'heroku'
end

group :production do
  gem 'newrelic_rpm'
end

# To use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'

# To use Jbuilder templates for JSON
# gem 'jbuilder'