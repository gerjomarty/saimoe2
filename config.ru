# This file is used by Rack-based servers to start the application.

require ::File.expand_path('../config/environment',  __FILE__)
# Hack to get carrierwave to work on Heroku
# See https://github.com/jnicklas/carrierwave/wiki/How-to%3A-Make-Carrierwave-work-on-Heroku
use Rack::Static, urls: %w(/carrierwave), root: 'tmp'
run Saimoe2::Application
