require "spec_helper"

describe Admin::CharactersController do
  describe "routing" do

    it "routes to #index" do
      get("/admin/characters").should route_to("admin/characters#index")
    end

    it "routes to #new" do
      get("/admin/characters/new").should route_to("admin/characters#new")
    end

    it "routes to #show" do
      get("/admin/characters/1").should route_to("admin/characters#show", :id => "1")
    end

    it "routes to #edit" do
      get("/admin/characters/1/edit").should route_to("admin/characters#edit", :id => "1")
    end

    it "routes to #create" do
      post("/admin/characters").should route_to("admin/characters#create")
    end

    it "routes to #update" do
      put("/admin/characters/1").should route_to("admin/characters#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/admin/characters/1").should route_to("admin/characters#destroy", :id => "1")
    end

  end
end
