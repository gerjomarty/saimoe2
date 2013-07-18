require 'alphabetical_pagination'

class VoiceActorsController < ApplicationController
  caches_action :index

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
    @tournament_history_view_model = TournamentHistoryViewModel.new(@voice_actor)
    @statistics_list_view_model = StatisticsListViewModel.new(Statistics.new(VoiceActor).get_statistic(:total_votes).for_entity(@voice_actor, true),
                                    comparison_statistics: Statistics.new(VoiceActor).get_statistic(:total_votes).before_date(Match.most_recent_finish_date),
                                    entities_to_bold: @voice_actor)

    if request.path != voice_actor_path(@voice_actor)
      redirect_to voice_actor_url(@voice_actor), status: :moved_permanently
      return
    end

    chars = Character.ordered.includes(:main_series)
                     .joins(:character_roles => {:appearances => :voice_actor_roles})
                     .where(:voice_actor_roles => {voice_actor_id: @voice_actor.id}).all.uniq.collect do |c|
                      CharacterEntry.new c, show_color: true, fixed_width: false
                     end

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
