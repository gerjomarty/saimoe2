class SeriesController < ApplicationController
  # GET /series
  def index
    @series = Series.ordered.all

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
