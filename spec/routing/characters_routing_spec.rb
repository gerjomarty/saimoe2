require 'spec_helper'

describe CharactersController do
  describe "routing" do
    it "routes to #index" do
      get("/characters").should route_to("characters#index")
    end

    it "routes to #show" do
      get("/characters/1").should route_to("characters#show", id: "1")
    end

    it "routes to #autocomplete" do
      get("/characters/autocomplete").should route_to("characters#autocomplete")
    end
  end
end
