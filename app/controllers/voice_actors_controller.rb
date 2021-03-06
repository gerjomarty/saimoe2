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

    @tournament_history_view_model = TournamentHistoryViewModel.new(@voice_actor)

    @vote_stats = StatisticsListViewModel.new(Statistics.new(VoiceActor).get_statistic(:total_votes).for_entity(@voice_actor, true),
                    comparison_statistics: Statistics.new(VoiceActor).get_statistic(:total_votes).before_date(Match.most_recent_finish_date),
                    entities_to_bold: @voice_actor)
    @appearance_stats = StatisticsListViewModel.new(Statistics.new(VoiceActor).get_statistic(:match_appearances).for_entity(@voice_actor, true),
                          comparison_statistics: Statistics.new(VoiceActor).get_statistic(:match_appearances).before_date(Match.most_recent_finish_date),
                          entities_to_bold: @voice_actor)
    @win_stats = StatisticsListViewModel.new(Statistics.new(VoiceActor).get_statistic(:match_wins).for_entity(@voice_actor, true),
                   comparison_statistics: Statistics.new(VoiceActor).get_statistic(:match_wins).before_date(Match.most_recent_finish_date),
                   entities_to_bold: @voice_actor)

    if (@tournament = Tournament.ordered.last).voice_actors.include?(@voice_actor)
      @current_vote_stats = StatisticsListViewModel.new(Statistics.new(VoiceActor).get_statistic(:total_votes).for_tournament(@tournament).for_entity(@voice_actor, true),
                              comparison_statistics: Statistics.new(VoiceActor).get_statistic(:total_votes).for_tournament(@tournament).before_date(Match.most_recent_finish_date),
                              entities_to_bold: @voice_actor)
      @current_appearance_stats = StatisticsListViewModel.new(Statistics.new(VoiceActor).get_statistic(:match_appearances).for_tournament(@tournament).for_entity(@voice_actor, true),
                                    comparison_statistics: Statistics.new(VoiceActor).get_statistic(:match_appearances).for_tournament(@tournament).before_date(Match.most_recent_finish_date),
                                    entities_to_bold: @voice_actor)
      @current_win_stats = StatisticsListViewModel.new(Statistics.new(VoiceActor).get_statistic(:match_wins).for_tournament(@tournament).for_entity(@voice_actor, true),
                             comparison_statistics: Statistics.new(VoiceActor).get_statistic(:match_wins).for_tournament(@tournament).before_date(Match.most_recent_finish_date),
                             entities_to_bold: @voice_actor)
    else
      @current_vote_stats = @current_appearance_stats = @current_win_stats = nil
    end

    chars = Character.ordered.includes(:main_series)
                     .joins(:character_roles => {:appearances => :voice_actor_roles})
                     .where(:voice_actor_roles => {voice_actor_id: @voice_actor.id}).all.uniq.collect do |c|
                      CharacterEntry.new c, cache: :voice_actor_char, show_color: true, fixed_width: false
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
