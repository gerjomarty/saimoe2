class Admin::CharactersController < Admin::AdminController
  # GET /admin/characters
  def index
    @characters = Character.includes(:main_series).ordered
  end

  # GET /admin/characters/new
  def new
    @character = Character.new
    @series = Series.ordered
    @tournaments = Tournament.ordered
  end

  # GET /admin/characters/1/edit
  def edit
    @character = Character.find(params[:id])
    @series = Series.ordered
    @tournaments = Tournament.ordered
  end

  # POST /admin/characters
  def create
    @character = Character.new(params[:character])
    @series = Series.ordered
    @tournaments = Tournament.ordered

    unless @character.main_series_id?
      if (new_series = params[:character_series][:new_main_series].strip.presence)
        @character.build_main_series name: new_series
      end
    end

    if @character.save
      redirect_to @character, notice: 'Character was successfully created.'
    else
      render action: 'new'
    end
  end

  # PUT /admin/characters/1
  def update
    @character = Character.find(params[:id])
    @series = Series.ordered
    @tournaments = Tournament.ordered

    if @character.update_attributes(params[:character])
      redirect_to edit_admin_character_path(@character), notice: 'Character was successfully updated.'
    else
      render action: 'edit'
    end
  end

  # DELETE /admin/characters/1
  def destroy
    @character = Character.find(params[:id])
    @character.destroy

    redirect_to admin_characters_url
  end
end
