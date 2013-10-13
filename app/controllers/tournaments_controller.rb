class TournamentsController < ApplicationController
  before_filter :set_tournament, except: :index
  before_filter :check_show_path, only: :show
  before_filter :check_stats_path, except: [:index, :show]

  # GET /tournaments
  def index
    @tournaments = Tournament.all
  end

  # GET /tournaments/1
  def show
    @tournament_view_model = TournamentViewModel.new(@tournament)
  end

  def characters_by_total_votes
    winners_only = params[:winners_only] == '1'
    stats = Statistics.new(Character).get_statistic(:total_votes).for_tournament(@tournament)
    comparison = Statistics.new(Character).get_statistic(:total_votes).for_tournament(@tournament).before_date(@tournament.most_recent_match_date)
    if winners_only
      stats = stats.for_winners_only
      comparison = comparison.for_winners_only
    end
    @view_model = StatisticsListViewModel.new(stats, cache: winners_only.to_s, comparison_statistics: @tournament.currently_on? ? comparison : nil)
  end

  def characters_by_average_votes
    stats = Statistics.new(Character).get_statistic(:average_votes).for_tournament(@tournament)
    comparison = Statistics.new(Character).get_statistic(:average_votes).for_tournament(@tournament).before_date(@tournament.most_recent_match_date)
    @view_model = StatisticsListViewModel.new(stats, comparison_statistics: @tournament.currently_on? ? comparison : nil)
  end

  def series_by_total_votes
    stats = Statistics.new(Series).get_statistic(:total_votes).for_tournament(@tournament)
    comparison = Statistics.new(Series).get_statistic(:total_votes).for_tournament(@tournament).before_date(@tournament.most_recent_match_date)
    @view_model = StatisticsListViewModel.new(stats, comparison_statistics: @tournament.currently_on? ? comparison : nil)
  end

  def voice_actors_by_total_votes
    stats = Statistics.new(VoiceActor).get_statistic(:total_votes).for_tournament(@tournament)
    comparison = Statistics.new(VoiceActor).get_statistic(:total_votes).for_tournament(@tournament).before_date(@tournament.most_recent_match_date)
    @view_model = StatisticsListViewModel.new(stats, comparison_statistics: @tournament.currently_on? ? comparison : nil)
  end

  def rounds_by_total_votes
    winners_only = params[:winners_only] == '1'
    stats = Statistics.new(Character).get_statistic(:total_votes).for_tournament(@tournament).in_stages
    comparison = Statistics.new(Character).get_statistic(:total_votes).for_tournament(@tournament).in_stages.before_date(@tournament.most_recent_match_date)
    if winners_only
      stats = stats.for_winners_only
      comparison = comparison.for_winners_only
    end
    @view_model = StatisticsListViewModel.new(stats, cache: winners_only.to_s, comparison_statistics: @tournament.currently_on? ? comparison : nil)
  end

  def rounds_by_vote_percentages
    winners_only = params[:winners_only] == '1'
    stats = Statistics.new(Character).get_statistic(:vote_share).for_tournament(@tournament).in_stages
    comparison = Statistics.new(Character).get_statistic(:vote_share).for_tournament(@tournament).in_stages.before_date(@tournament.most_recent_match_date)
    if winners_only
      stats = stats.for_winners_only
      comparison = comparison.for_winners_only
    end
    @view_model = StatisticsListViewModel.new(stats, cache: winners_only.to_s, comparison_statistics: @tournament.currently_on? ? comparison : nil)
  end

  def rounds_by_series_prevalence
    stats = Statistics.new(Series).get_statistic(:match_appearances).for_tournament(@tournament).in_stages
    comparison = Statistics.new(Series).get_statistic(:match_appearances).for_tournament(@tournament).in_stages.before_date(@tournament.most_recent_match_date)
    @view_model = StatisticsListViewModel.new(stats, comparison_statistics: @tournament.currently_on? ? comparison : nil)
  end

  def rounds_by_voice_actor_prevalence
    stats = Statistics.new(VoiceActor).get_statistic(:match_appearances).for_tournament(@tournament).in_stages
    comparison = Statistics.new(VoiceActor).get_statistic(:match_appearances).for_tournament(@tournament).in_stages.before_date(@tournament.most_recent_match_date)
    @view_model = StatisticsListViewModel.new(stats, comparison_statistics: @tournament.currently_on? ? comparison : nil)
  end

  private

  def set_tournament
    @tournament = params[:year] ? Tournament.where(year: params[:year]).first : Tournament.find(params[:id])

    unless @tournament
      flash[:alert] = 'Tournament cound not be found.'
      redirect_to tournaments_path
    end
  end

  def check_show_path
    if request.path != short_tournament_path(@tournament.year)
      redirect_to short_tournament_url(@tournament.year), status: :moved_permanently
    end
  end

  def check_stats_path
    if request.path != short_tournament_action_path(@tournament.year, action_name)
      redirect_to short_tournament_action_path(@tournament.year, action_name), status: :moved_permanently
    end
  end
end
