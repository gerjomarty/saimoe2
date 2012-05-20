require 'spec_helper'

describe SeriesController do
  describe "routing" do

    it "routes to #index" do
      get("/series").should route_to("series#index")
    end

    it "routes to #show" do
      get("/series/1").should route_to("series#show", :id => "1")
    end

    it "routes to #autocomplete" do
      get("/series/autocomplete").should route_to("series#autocomplete")
    end
  end
end
