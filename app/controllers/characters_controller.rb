class CharactersController < ApplicationController
  # GET /characters
  def index
    @characters = Character.ordered.all

    respond_to do |format|
      format.html # index.html.erb
    end
  end

  # GET /characters/1
  def show
    @character = Character.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
    end
  end
end
