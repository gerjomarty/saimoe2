require 'alphabetical_pagination'

class SeriesController < ApplicationController
  caches_action :index

  # GET /series
  def index
    @ap = AlphabeticalPagination.new
    @ap.relation = Series.ordered
    @ap.letter_method = Proc.new {|s| s.sortable_name}
    @ap.default_letter = '#'
    @ap.no_of_columns = 4

    @ap.get_data
  end

  # GET /series/1
  def show
    @series = Series.find(params[:id])

    if request.path != series_path(@series)
      redirect_to series_url(@series), status: :moved_permanently
      return
    end

    majors = Character.ordered.joins(:character_roles)
                              .where(:character_roles => {role_type: :major, series_id: @series.id}).all
    cameos = Character.ordered.includes(:main_series).joins(:character_roles)
                              .where(:character_roles => {role_type: :cameo, series_id: @series.id}).all

    m_size, m_rem = majors.size.divmod 4
    @major_chars = ([m_size]*4).collect.with_index {|s, i|
      s += 1 if i < m_rem
      majors.slice!(0...s)
    }.reject(&:empty?)

    c_size, c_rem = cameos.size.divmod 4
    @cameo_chars = ([c_size]*4).collect.with_index {|s, i|
      s += 1 if i < c_rem
      cameos.slice!(0...s)
    }.reject(&:empty?)
  end

  # GET /series/autocomplete
  def autocomplete
    render json: Series.search(params[:term])
  end
end
