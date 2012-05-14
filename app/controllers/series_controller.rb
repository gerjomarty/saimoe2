require "#{Rails.root}/lib/alphabetical_pagination"

class SeriesController < ApplicationController
  # GET /series
  def index
    @ap = AlphabeticalPagination.new
    @ap.relation = Series.ordered
    @ap.letter_method = Proc.new {|s| s.name}
    @ap.default_letter = '#'
    @ap.no_of_columns = 3

    @ap.get_data

    respond_to do |format|
      format.html # index.html.erb
    end
  end

  # GET /series/1
  def show
    @series = Series.find(params[:id])

    if request.path != series_path(@series)
      return redirect_to series_url(@series), status: :moved_permanently
    end

    respond_to do |format|
      format.html # show.html.erb
    end
  end
end
