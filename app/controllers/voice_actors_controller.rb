class VoiceActorsController < ApplicationController
  # GET /voice_actors
  def index
    @voice_actors = VoiceActor.ordered.all

    respond_to do |format|
      format.html # index.html.erb
    end
  end

  # GET /voice_actors/1
  def show
    @voice_actor = VoiceActor.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
    end
  end
end
