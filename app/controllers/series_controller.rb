require 'alphabetical_pagination'

class SeriesController < ApplicationController
  # GET /series
  def index
    @ap = AlphabeticalPagination.new
    @ap.relation = Series.ordered
    @ap.letter_method = Proc.new {|s| s.name}
    @ap.default_letter = '#'
    @ap.no_of_columns = 4

    @ap.get_data
  end

  # GET /series/1
  def show
    @series = Series.find(params[:id])

    if request.path != series_path(@series)
      redirect_to series_url(@series), status: :moved_permanently
    end
  end

  # GET /series/autocomplete
  def autocomplete
    render json: Series.search(params[:term])
  end
end
