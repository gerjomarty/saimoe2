require 'alphabetical_pagination'

class SeriesController < ApplicationController

  # GET /series
  def index
    @ap = AlphabeticalPagination.new
    @ap.relation = Series.ordered
    @ap.letter_method = Proc.new {|s| s.sortable_name}
    @ap.default_letter = '#'
    @ap.no_of_columns = 4

    @ap.get_data
  end

  # GET /series/1
  def show
    @series = Series.find(params[:id])
    @tournament_history_view_model = TournamentHistoryViewModel.new(@series)

    @vote_stats = StatisticsListViewModel.new(Statistics.new(Series).get_statistic(:total_votes).for_entity(@series, true),
                    comparison_statistics: Statistics.new(Series).get_statistic(:total_votes).before_date(Match.most_recent_finish_date),
                    entities_to_bold: @series)
    @appearance_stats = StatisticsListViewModel.new(Statistics.new(Series).get_statistic(:match_appearances).for_entity(@series, true),
                          comparison_statistics: Statistics.new(Series).get_statistic(:match_appearances).before_date(Match.most_recent_finish_date),
                          entities_to_bold: @series)
    @win_stats = StatisticsListViewModel.new(Statistics.new(Series).get_statistic(:match_wins).for_entity(@series, true),
                   comparison_statistics: Statistics.new(Series).get_statistic(:match_wins).before_date(Match.most_recent_finish_date),
                   entities_to_bold: @series)

    if (@tournament = Tournament.ordered.last).series.include?(@series)
      @current_vote_stats = StatisticsListViewModel.new(Statistics.new(Series).get_statistic(:total_votes).for_tournament(@tournament).for_entity(@series, true),
                              comparison_statistics: Statistics.new(Series).get_statistic(:total_votes).for_tournament(@tournament).before_date(Match.most_recent_finish_date),
                              entities_to_bold: @series)
      @current_appearance_stats = StatisticsListViewModel.new(Statistics.new(Series).get_statistic(:match_appearances).for_tournament(@tournament).for_entity(@series, true),
                                    comparison_statistics: Statistics.new(Series).get_statistic(:match_appearances).for_tournament(@tournament).before_date(Match.most_recent_finish_date),
                                    entities_to_bold: @series)
      @current_win_stats = StatisticsListViewModel.new(Statistics.new(Series).get_statistic(:match_wins).for_tournament(@tournament).for_entity(@series, true),
                             comparison_statistics: Statistics.new(Series).get_statistic(:match_wins).for_tournament(@tournament).before_date(Match.most_recent_finish_date),
                             entities_to_bold: @series)
    else
      @current_vote_stats = @current_appearance_stats = @current_win_stats = nil
    end

    if request.path != series_path(@series)
      redirect_to series_url(@series), status: :moved_permanently
      return
    end

    majors = Character.ordered.joins(:character_roles)
                              .where(:character_roles => {role_type: :major, series_id: @series.id}).all.collect do |c|
                                CharacterEntry.new c, cache: :series_major_chars, show_color: true, fixed_width: false, show_series: false
                              end
    cameos = Character.ordered.includes(:main_series).joins(:character_roles)
                              .where(:character_roles => {role_type: :cameo, series_id: @series.id}).all.collect do |c|
                                CharacterEntry.new c, cache: :series_cameo_chars, show_color: true, fixed_width: false
                              end

    m_size, m_rem = majors.size.divmod 4
    @major_chars = ([m_size]*4).collect.with_index {|s, i|
      s += 1 if i < m_rem
      majors.slice!(0...s)
    }.reject(&:empty?)

    c_size, c_rem = cameos.size.divmod 4
    @cameo_chars = ([c_size]*4).collect.with_index {|s, i|
      s += 1 if i < c_rem
      cameos.slice!(0...s)
    }.reject(&:empty?)
  end

  # GET /series/autocomplete
  def autocomplete
    render json: Series.search(params[:term])
  end
end
