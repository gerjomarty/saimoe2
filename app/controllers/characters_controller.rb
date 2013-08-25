require 'alphabetical_pagination'

class CharactersController < ApplicationController

  # GET /characters
  def index
    @ap = AlphabeticalPagination.new
    @ap.relation = Character.ordered_by_main_series
    @ap.secondary_method = Proc.new {|c| c.main_series}
    @ap.letter_method = Proc.new {|c| c.main_series.sortable_name}
    @ap.default_letter = '#'
    @ap.no_of_columns = 4

    @ap.get_data
  end

  # GET /characters/1
  def show
    @character = Character.find(params[:id])
    @tournament_history_view_model = TournamentHistoryViewModel.new(@character)
    @vote_stats = StatisticsListViewModel.new(Statistics.new(Character).get_statistic(:total_votes).for_entity(@character, true),
                    comparison_statistics: Statistics.new(Character).get_statistic(:total_votes).before_date(Match.most_recent_finish_date),
                    entities_to_bold: @character)
    @appearance_stats = StatisticsListViewModel.new(Statistics.new(Character).get_statistic(:match_appearances).for_entity(@character, true),
                          comparison_statistics: Statistics.new(Character).get_statistic(:match_appearances).before_date(Match.most_recent_finish_date),
                          entities_to_bold: @character)
    @win_stats = StatisticsListViewModel.new(Statistics.new(Character).get_statistic(:match_wins).for_entity(@character, true),
                   comparison_statistics: Statistics.new(Character).get_statistic(:match_wins).before_date(Match.most_recent_finish_date),
                   entities_to_bold: @character)

    if request.path != character_path(@character)
      redirect_to character_url(@character), status: :moved_permanently
    end
  end

  # GET /characters/autocomplete
  def autocomplete
    render json: Character.search(params[:term])
  end
end
