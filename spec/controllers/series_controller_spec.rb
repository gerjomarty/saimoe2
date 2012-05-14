require 'spec_helper'

describe SeriesController do
  before :each do
    @series = create :series
  end

  describe "#index" do
    before :each do
      get :index
    end

    it { should respond_with(:success) }
    it { should render_template(:index) }
    it { should_not set_the_flash }

    it "assigns all series as @series" do
      assigns(:ap).get_data.should == [{'S' => [@series]}]
    end
  end

  describe "#show" do
    before :each do
      get :show, id: @series.to_param
    end

    it { should respond_with(:success) }
    it { should render_template(:show) }
    it { should_not set_the_flash }

    it "assigns the requested series as @series" do
      assigns(:series).should == @series
    end
  end
end
