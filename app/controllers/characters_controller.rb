require "#{Rails.root}/lib/alphabetical_pagination"

class CharactersController < ApplicationController
  # GET /characters
  def index
    @ap = AlphabeticalPagination.new
    @ap.relation = Character.ordered_by_main_series
    @ap.secondary_method = Proc.new {|c| c.main_series}
    @ap.letter_method = Proc.new {|c| c.main_series.name}
    @ap.default_letter = '#'
    @ap.no_of_columns = 3

    @ap.get_data

    respond_to do |format|
      format.html # index.html.erb
    end
  end

  # GET /characters/1
  def show
    @character = Character.find(params[:id])

    if request.path != character_path(@character)
      return redirect_to character_url(@character), status: :moved_permanently
    end

    respond_to do |format|
      format.html # show.html.erb
    end
  end
end
