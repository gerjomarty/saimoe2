class ApplicationController < ActionController::Base
  protect_from_forgery

  # GET /autocomplete
  def autocomplete
    render json: [Character, Series, VoiceActor].collect { |model|
      model.search(params[:term])
    }.inject(:+)
  end
end
