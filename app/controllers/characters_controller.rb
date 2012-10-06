require 'alphabetical_pagination'

class CharactersController < ApplicationController
  caches_action :index

  # GET /characters
  def index
    @ap = AlphabeticalPagination.new
    @ap.relation = Character.ordered_by_main_series
    @ap.secondary_method = Proc.new {|c| c.main_series}
    @ap.letter_method = Proc.new {|c| c.main_series.sortable_name}
    @ap.default_letter = '#'
    @ap.no_of_columns = 4

    @ap.get_data
  end

  # GET /characters/1
  def show
    @character = Character.find(params[:id])

    if request.path != character_path(@character)
      redirect_to character_url(@character), status: :moved_permanently
    end
  end

  # GET /characters/autocomplete
  def autocomplete
    render json: Character.search(params[:term])
  end
end
