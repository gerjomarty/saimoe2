class HomeController < ApplicationController
  layout 'tournaments'

  caches_action :index

  def index
    @most_recent = Match.ordered_by_date.where(is_finished: true, date: Match.where(is_finished: true).maximum(:date))
    @todays_matches = Match.ordered_by_date.where("is_finished IS NULL OR is_finished = ?", false).where(date: Match.where("is_finished IS NULL OR is_finished = ?", false).minimum(:date))

    @tournament = @most_recent.try(:first).try(:tournament) || Tournament.fy(Time.zone.now.year)

    #TODO: Don't just copy this from tournaments/show - actually use same code in a DRY way

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

    #TODO: End of bad repeated block
  end
end
