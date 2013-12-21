class Admin::SeriesController < Admin::AdminController
  # GET /admin/series
  def index
    @series = Series.ordered
  end

  # GET /admin/series/new
  def new
    @series = Series.new
  end

  # GET /admin/series/1/edit
  def edit
    @series = Series.find(params[:id])
  end

  # POST /admin/series
  def create
    @series = Series.new(params[:series])

    if @series.save
      redirect_to @series, notice: 'Series was successfully created.'
    else
      render action: 'new'
    end
  end

  # PUT /admin/series/1
  def update
    @series = Series.find(params[:id])

    if @series.update_attributes(params[:series])
      redirect_to edit_admin_series_path(@series), notice: 'Series was successfully updated.'
    else
      render action: 'edit'
    end
  end

  # DELETE /admin/series/1
  def destroy
    @series = Series.find(params[:id])
    @series.destroy

    redirect_to admin_series_index_url
  end
end