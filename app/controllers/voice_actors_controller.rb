require "#{Rails.root}/lib/alphabetical_pagination"

class VoiceActorsController < ApplicationController
  # GET /voice_actors
  def index
    @ap = AlphabeticalPagination.new
    @ap.relation = VoiceActor.ordered
    @ap.letter_method = Proc.new {|va| va.last_name || va.first_name}
    @ap.no_of_columns = 3

    @ap.get_data

    respond_to do |format|
      format.html # index.html.erb
    end
  end

  # GET /voice_actors/1
  def show
    @voice_actor = VoiceActor.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
    end
  end
end
