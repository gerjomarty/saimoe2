class HomeController < ApplicationController
  layout 'tournaments'

  caches_action :index

  def index
    @most_recent = Match.ordered_by_date.where(is_finished: true, date: Match.where(is_finished: true).maximum(:date))

    @tournament = @most_recent.try(:first).try(:tournament) || Tournament.fy(Time.zone.now.year)

    @tournament_view_model = TournamentViewModel.new(@tournament) if @tournament
  end
end
