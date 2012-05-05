require 'spec_helper'

describe Series do
  it { should have_many(:main_characters) }
  it { should have_many(:character_roles) }

  it { should validate_presence_of(:name) }
  it { should allow_value('ABCDEF').for(:color_code) }
  it { should_not allow_value('khgrds').for(:color_code) }
  it { should_not allow_value('123').for(:color_code) }

  it "should upcase submitted color codes" do
    series = build(:series, color_code: '17dead')
    series.color_code.should == "17DEAD"
  end

  describe "#ordered" do
    before :each do
      %w{Alpha Bravo Charlie}.shuffle.each {|name| create(:series, name: name) }
    end

    context "normally ordered" do
      subject { Series.ordered.all }

      its(:size) { should == 3 }
      its([0]) { should == Series.where(name: "Alpha").first! }
      its([1]) { should == Series.where(name: "Bravo").first! }
      its([2]) { should == Series.where(name: "Charlie").first! }
    end

    context "reverse ordered" do
      subject { Series.ordered.reverse_order.all }

      its(:size) { should == 3 }
      its([2]) { should == Series.where(name: "Alpha").first! }
      its([1]) { should == Series.where(name: "Bravo").first! }
      its([0]) { should == Series.where(name: "Charlie").first! }
    end
  end
end
