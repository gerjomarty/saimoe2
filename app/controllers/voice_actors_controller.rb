require 'alphabetical_pagination'

class VoiceActorsController < ApplicationController
  # GET /voice-actors
  def index
    @ap = AlphabeticalPagination.new
    @ap.relation = VoiceActor.ordered
    @ap.letter_method = Proc.new {|va| va.last_name || va.first_name}
    @ap.no_of_columns = 4

    @ap.get_data
  end

  # GET /voice-actors/1
  def show
    @voice_actor = VoiceActor.find(params[:id])

    if request.path != voice_actor_path(@voice_actor)
      redirect_to voice_actor_url(@voice_actor), status: :moved_permanently
    end
  end

  # GET /voice-actors/autocomplete
  def autocomplete
    render json: VoiceActor.search(params[:term])
  end
end
