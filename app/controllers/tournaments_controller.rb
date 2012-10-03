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
    @group_stage_matches = {}.tap do |sgm|
      @tournament.matches.group_matches.without_playoffs.ordered
      .includes(:match_entries => [:previous_match, {:appearance => {:character_role => [:character, :series]}}]).each do |match|
        stage = match.stage
        group = match.group
        sgm[group] ||= {}
        sgm[group][stage] ||= []
        sgm[group][stage] << match
      end
    end

    @final_stage_matches = {}.tap do |fm|
      @tournament.matches.final_matches.ordered
      .includes(:match_entries => {:appearance => {:character_role => [:character, :series]}}).each do |match|
        stage = match.stage
        fm[stage] ||= []
        fm[stage] << match
      end
    end

  end

  def characters_by_total_votes
    @results = @tournament.characters_by_total_votes
  end

  def characters_by_average_votes
    @results = @tournament.characters_by_average_votes
  end

  def series_by_total_votes
    @results = @tournament.series_by_total_votes
  end

  def voice_actors_by_total_votes
    @results = @tournament.voice_actors_by_total_votes
  end

  def rounds_by_total_votes
    @results = @tournament.stages_by_total_votes
  end

  def rounds_by_vote_percentages
    @results = @tournament.stages_by_vote_shares
  end

  def rounds_by_series_prevalence
    @results = @tournament.stages_by_series_prevalence
  end

  def rounds_by_voice_actor_prevalence
    @results = @tournament.stages_by_voice_actor_prevalence
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
