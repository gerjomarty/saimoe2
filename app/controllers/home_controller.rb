class HomeController < ApplicationController
  layout 'tournaments'

  caches_action :index

  def index
    @most_recent = Match.ordered_by_date.where(is_finished: true, date: Match.where(is_finished: true).maximum(:date))

    @tournament = @most_recent.try(:first).try(:tournament) || Tournament.fy(Time.zone.now.year)

    #TODO: Don't just copy this from tournaments/show - actually use same code in a DRY way

    @group_matches_in_progress = false
    @group_stage_matches = {}.tap do |sgm|
      @tournament.matches.group_matches.without_playoffs.ordered
      .includes(:match_entries => [:previous_match, {:appearance => {:character_role => [:character, :series]}}]).each do |match|
        stage = match.stage
        group = match.group
        sgm[group] ||= {}
        sgm[group][stage] ||= []
        sgm[group][stage] << match
        @group_matches_in_progress = true unless match.is_finished?
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
