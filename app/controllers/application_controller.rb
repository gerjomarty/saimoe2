class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :force_http

  def force_http
    redirect_to protocol: 'http://'
    true
  end
end
