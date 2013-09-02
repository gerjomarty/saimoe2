class HomeController < ApplicationController
  layout 'tournaments'

  def index
    @most_recent_view_models = Match.ordered_by_date
                                    .where(is_finished: true,
                                           date: Match.where(is_finished: true).maximum(:date)).collect do |m|
                                             MatchViewModel.new(m, cache: :home_most_recent, match_name: :short, show_percentages: true, match_entry_ordering: :ordered_by_votes)
                                           end

    @todays_match_view_models =
      if ((scope = Match.ordered_by_date.where(is_finished: false, date: Time.zone.now.to_date).scoped).any?) ||
          ((scope = Match.ordered_by_date.where(is_finished: false, date: Time.zone.now.to_date + 1).scoped).any?)
        scope.collect {|m| MatchViewModel.new(m, cache: :home_todays_matches, match_name: :short, schema_markup: true) }
      else
        nil
      end

    unless @todays_match_view_models
      @next_match_date = Match.ordered_by_date
                              .select(Match.q_column :date)
                              .where(is_finished: false).first.try(:date)
    end

    @tournament = Tournament.ordered.last
    @tournament_view_model = TournamentViewModel.new(@tournament) if @tournament
  end
end
