class TournamentsController < ApplicationController
  # GET /tournaments
  def index
    @tournaments = Tournament.all
  end

  # GET /tournaments/1
  def show
    @tournament = params[:year] ? Tournament.where(year: params[:year]).first! : Tournament.find(params[:id])

    @group_stage_matches = {}.tap do |sgm|
      @tournament.matches.group_matches.without_playoffs.ordered
      .includes(:match_entries => [:previous_match, {:appearance => {:character_role => [:character, :series]}}]).each do |match|
        stage = match.stage
        group = match.group
        sgm[group] ||= {}
        sgm[group][:hierarchy] = match.match_hierarchy if stage == @tournament.group_stages.last
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
end
