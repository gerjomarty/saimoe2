require 'spec_helper'

describe VoiceActorsController do
  before :each do
    @voice_actor = create :voice_actor
  end

  describe "#index" do
    before :each do
      get :index
    end

    it { should respond_with(:success) }
    it { should render_template(:index) }
    it { should_not set_the_flash }

    it "assigns all voice actors as @voice_actors" do
      assigns(:voice_actors).should == [@voice_actor]
    end
  end

  describe "#show" do
    before :each do
      get :show, id: @voice_actor.to_param
    end

    it { should respond_with(:success) }
    it { should render_template(:show) }
    it { should_not set_the_flash }

    it "assigns the requested voice actor as @voice_actor" do
      assigns(:voice_actor).should == @voice_actor
    end
  end
end
