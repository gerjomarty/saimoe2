source 'https://rubygems.org'

gem 'rails', '3.2.3'
gem 'pg'
gem 'jquery-rails'
gem 'thin'

group :assets do
  gem 'coffee-rails', '~> 3.2.1'
  gem 'uglifier', '>= 1.0.3'
  gem 'twitter-bootstrap-rails'
end

group :production do
  gem 'newrelic_rpm'
end

group :test, :development do
  gem 'rspec-rails'
end

group :development do
  gem 'heroku'
  gem 'ruby-debug19', require: 'ruby-debug'
end

group :test do
  gem 'rake'
  gem 'factory_girl_rails'
  gem 'acts_as_fu'
  gem 'mocha'
end

# To use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'

# To use Jbuilder templates for JSON
# gem 'jbuilder'
