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

    @date_match_view_models = Match.ordered.where(date: @date).collect do |m|
      DateMatchViewModel.new(m)
    end

    if @date_match_view_models.empty?
      redirect_to tournaments_path, notice: "No matches found for that date"
      return
    end

    @tournament = @date_match_view_models.first.match.tournament
  end
end
