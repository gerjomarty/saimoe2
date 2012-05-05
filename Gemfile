source 'https://rubygems.org'

gem 'rails', '= 3.2.3'
gem 'pg'
gem 'thin'
gem 'jquery-rails', '~> 2.0.0'

group :assets do
  gem 'coffee-rails', '~> 3.2.1'
  gem 'uglifier', '>= 1.0.3'
  gem 'twitter-bootstrap-rails', '~> 2.0.0'
end

group :test, :development do
  gem 'rspec-rails', '~> 2.9.0'
end

group :test do
  gem 'rake'
  gem 'factory_girl_rails', '~> 3.2.0'
  gem 'acts_as_fu', '~> 0.0.0', require: false
  gem 'mocha', '~> 0.11.0'
  gem 'shoulda-matchers', '~> 1.1.0'
  gem 'simplecov', '~> 0.6.0', require: false
end

group :development do
  gem 'heroku'
  gem 'ruby-debug19', require: 'ruby-debug'
end

group :production do
  gem 'newrelic_rpm', '~> 3.3.0'
end

# To use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'

# To use Jbuilder templates for JSON
# gem 'jbuilder'
