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
      return
    end

    chars = Character.ordered.joins(:character_roles => {:appearances => :voice_actor_roles})
                     .where(:character_roles => {:appearances => {:voice_actor_roles => {voice_actor_id: @voice_actor.id}}}).all.uniq

    c_size, c_rem = chars.size.divmod 4
    @chars = ([c_size]*4).collect.with_index {|s, i|
      s += 1 if i < c_rem
      chars.slice!(0...s)
    }
  end

  # GET /voice-actors/autocomplete
  def autocomplete
    render json: VoiceActor.search(params[:term])
  end
end
