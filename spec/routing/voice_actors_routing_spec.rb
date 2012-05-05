require "spec_helper"

describe VoiceActorsController do
  describe "routing" do

    it "routes to #index" do
      get("/voice-actors").should route_to("voice_actors#index")
    end

    it "routes to #show" do
      get("/voice-actors/1").should route_to("voice_actors#show", :id => "1")
    end

  end
end
