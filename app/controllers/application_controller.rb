class ApplicationController < ActionController::Base
  protect_from_forgery

  # GET /autocomplete
  def autocomplete
    render json: [Character, Series, VoiceActor].collect do |model|
      model.search(params[:term])
    end.inject(:+)
  end
end
