require 'spec_helper'

describe Tournament do
  it { should have_many(:appearances) }
  it { should have_many(:matches) }

  it { should validate_presence_of(:year) }
  it { should allow_value('2046').for(:year) }
  it { should_not allow_value('201').for(:year) }
  it { should_not allow_value('ABCD').for(:year) }

  it "validates uniqueness of year" do
    create :tournament
    should validate_uniqueness_of(:year)
  end

  describe "#fy" do
    t = FactoryGirl.create(:tournament)
    Tournament.fy(2000).should == t
  end
end
