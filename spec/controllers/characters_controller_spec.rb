require 'spec_helper'

describe CharactersController do
  before :each do
    @character = create :character
  end

  describe "#index" do
    before :each do
      get :index
    end

    it { should respond_with(:success) }
    it { should render_template(:index) }
    it { should_not set_the_flash }

    it "assigns all characters as @characters" do
      assigns(:characters).should == [@character]
    end
  end

  describe "#show" do
    before :each do
      get :show, id: @character.to_param
    end

    it { should respond_with(:success) }
    it { should render_template(:show) }
    it { should_not set_the_flash }

    it "assigns the requested character as @character" do
      assigns(:character).should == @character
    end
  end
end
