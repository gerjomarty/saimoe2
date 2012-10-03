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

    @matches = Match.find_all_by_date @date

    if @matches.empty?
      redirect_to tournaments_path, notice: "No matches found for that date"
      return
    end

    @tournament = @matches.first.tournament
  end
end
