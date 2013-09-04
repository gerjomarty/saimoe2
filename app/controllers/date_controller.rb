class DateController < ApplicationController
  layout 'tournaments'

  def show
    @date = nil
    begin
      @date = Date.parse params[:date]
    rescue ArgumentError
      redirect_to tournaments_path, notice: "Please enter a valid date"
      return
    end

    matches = Match.ordered.where(date: @date)

    if matches.empty?
      redirect_to tournaments_path, notice: "No matches found for that date"
      return
    end

    if matches.size > 1
      match_entries = matches.collect(&:match_entries).flatten

      max_votes = match_entries.max_by(&:number_of_votes).number_of_votes
      min_votes = match_entries.min_by(&:number_of_votes).number_of_votes
    else
      max_votes = min_votes = nil
    end

    @date_match_view_models = matches.collect do |m|
      DateMatchViewModel.new(m, percentage_width_max_votes: max_votes, percentage_width_min_votes: min_votes)
    end

    if @date_match_view_models.empty?
      redirect_to tournaments_path, notice: "No matches found for that date"
      return
    end

    @tournament = @date_match_view_models.first.match.tournament
  end
end
